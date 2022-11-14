#!/usr/bin/env bash
set -e

export KUBECONFIG_BASE64="${BITOPS_KUBECONFIG_BASE64}"
export HELM_CHART="$1"
export SCRIPTS_DIR="$BITOPS_PLUGIN_DIR/scripts"
export BITOPS_CONFIG_SCHEMA="$BITOPS_PLUGIN_DIR/bitops.schema.yaml"
export BITOPS_SCHEMA_ENV_FILE="$BITOPS_OPSREPO_ENVIRONMENT_DIR/$HELM_CHART/ENV_FILE"
export HELM_BITOPS_CONFIG="$BITOPS_OPSREPO_ENVIRONMENT_DIR/$HELM_CHART/bitops.config.yaml"
export HELM_CHART_DIRECTORY="$BITOPS_OPSREPO_ENVIRONMENT_DIR/$HELM_CHART"

echo "Parsing helm bitops.config.yaml..."
export BITOPS_CONFIG_COMMAND="$(ENV_FILE="$BITOPS_SCHEMA_ENV_FILE" DEBUG="" bash $SCRIPTS_DIR/bitops-config/convert-schema.sh $BITOPS_CONFIG_SCHEMA $HELM_BITOPS_CONFIG)"

echo "BITOPS_CONFIG_COMMAND: $BITOPS_CONFIG_COMMAND"
source "$BITOPS_SCHEMA_ENV_FILE"

# Check for helm skip deploy condition
if [ "$HELM_SKIP_DEPLOY" == "true" ]; then
    echo "helm.options.skip-deploy (HELM_SKIP_DEPLOY) set.  Skipping deployment for $ENVIRONMENT/helm/$HELM_CHART"
    exit 0
fi

# Check for dependent aws plugin
if [ ! -d $PLUGINS_ROOT_DIR/aws ]; then
    echo "aws plugin is missing..."
    exit 1
else
    # Check for dependent kubectl plugin
    if [ ! -d $PLUGINS_ROOT_DIR/kubectl ]; then
    echo "kubectl plugin is missing..."
    exit 1
    else
    echo "All dependent plugins found. Continuing with deployment.."
    fi
fi

# Check for Before Deploy Scripts
bash $SCRIPTS_DIR/before-deploy.sh "$HELM_CHART_DIRECTORY"

# set kube config
if [[ -z "$KUBECONFIG_BASE64" ]]; then
    if [[ "${KUBE_CONFIG_PATH}" == "" ]] || [[ "${KUBE_CONFIG_PATH}" == "''" ]] || [[ "${KUBE_CONFIG_PATH}" == "None" ]]; then
        if [[ "${FETCH_KUBECONFIG}" == "True" ]]; then
            if [[ "${CLUSTER_NAME}" == "" ]] || [[ "${CLUSTER_NAME}" == "''" ]] || [[ "${CLUSTER_NAME}" == "None" ]]; then
                >&2 echo "{\"error\":\"CLUSTER_NAME config is required.Exiting...\"}"
                exit 1
            else
                # always get the kubeconfig (whether or not we applied)
                echo "Attempting to fetch KUBECONFIG from cloud provider..."
                CLUSTER_NAME="$CLUSTER_NAME" \
                KUBECONFIG="$BITOPS_KUBE_CONFIG_FILE" \
                bash $PLUGINS_ROOT_DIR/aws/eks.update-kubeconfig.sh
                export KUBECONFIG=$KUBECONFIG:$BITOPS_KUBE_CONFIG_FILE
                export k="kubectl --kubeconfig=$BITOPS_KUBE_CONFIG_FILE"
                export h="helm --kubeconfig=$BITOPS_KUBE_CONFIG_FILE"
            fi
        else
            if [[ "${FETCH_KUBECONFIG}" == "False" ]]; then
                >&2 echo "{\"error\":\"'kubeconfig' cannot be false when 'cluster-name' variable is defined in bitops.config.yaml.Exiting...\"}"
                exit 1
            fi
        fi
    else
        if [[ -f "$KUBE_CONFIG_PATH" ]]; then
            echo "$KUBE_CONFIG_PATH exists."
            KUBE_CONFIG_FILE="$KUBE_CONFIG_PATH"
            KUBECONFIG="$KUBE_CONFIG_FILE"
            export KUBECONFIG=$KUBECONFIG:$KUBE_CONFIG_FILE
            export k="kubectl --kubeconfig=$KUBE_CONFIG_FILE"
            export h="helm --kubeconfig=$KUBE_CONFIG_FILE"
        else
            >&2 echo "{\"error\":\"kubeconfig path set in bitops.config.yaml but not found.Exiting...\"}"
            exit 1
        fi
    fi
else
    echo "Running kubectl plugin"
    bash $PLUGINS_ROOT_DIR/kubectl/scripts/kubeconfig_base64_decode.sh
    # cat $BITOPS_KUBE_CONFIG_FILE
    export k="kubectl --kubeconfig=$BITOPS_KUBE_CONFIG_FILE"
    export h="helm --kubeconfig=$BITOPS_KUBE_CONFIG_FILE"

fi


echo "call validate_env with NAMESPACE: $NAMESPACE"
if [ -n "$HELM_RELEASE_NAME" ]; then
    export HELM_RELEASE_NAME="$HELM_CHART"
fi
bash $SCRIPTS_DIR/validate_env.sh
echo "validate_env for NAMESPACE: $NAMESPACE completed successfully"

echo "Identify the default sub directory for $HELM_CHART helm chart"
if [ -z "$DEFAULT_SUB_DIR" ]; then
    echo "DEFAULT_SUB_DIR is not set. Setting to $HELM_CHART"
    DEFAULT_SUB_DIR="helm/$HELM_CHART"
else
    echo "DEFAULT_SUB_DIR is set: $DEFAULT_SUB_DIR"
fi

if [ -z $BITOPS_PLUGIN_NAME ]; then
    # BITOPS_PLUGIN_NAME is empty, assuming plugin name based on basename
    BITOPS_PLUGIN_NAME=$(basename ${BITOPS_PLUGIN_DIR})
fi

# # Identify the default folder for helm
echo "Identify the default root folder for $HELM_CHART helm chart"
if [[ "${DEFAULT_DIR_FLAG}" == "True" ]]; then
    echo "Use 'opsrepo_root_default_dir' of bitops.config.yaml build config value for default root directory..."
    export DEFAULT_HELM_ROOT="$BITOPS_TEMPDIR/$BITOPS_DEFAULT_ROOT_DIR/$BITOPS_PLUGIN_NAME"
else
    echo "Use 'default-root-dir' of bitops.config.yaml helm chart config value for default root directory..."
    export DEFAULT_HELM_ROOT="$BITOPS_OPSREPO_ENVIRONMENT_DIR/$DEFAULT_ROOT_DIR"
fi

export DEFAULT_HELM_CHART_DIRECTORY="$DEFAULT_HELM_ROOT/$HELM_CHART"
echo "Using default folder [$DEFAULT_HELM_CHART_DIRECTORY]"

### COPY DEFAULTS
echo "Copying defaults...."
HELM_CHART_DIRECTORY="$HELM_CHART_DIRECTORY" \
DEFAULT_HELM_CHART_DIRECTORY="$DEFAULT_HELM_CHART_DIRECTORY" \
HELM_BITOPS_CONFIG="$HELM_BITOPS_CONFIG" \
bash -x $SCRIPTS_DIR/copy-defaults.sh "$HELM_CHART"
echo "Copy defaults completed...."

# Check if chart is flagged for removal
CHART_IN_UNINSTALL_LIST=false
IFS=',' read -ra CHART_ARRAY <<< "$HELM_UNINSTALL_CHARTS"
for CHART in "${CHART_ARRAY[@]}"; do
    if [ "$HELM_RELEASE_NAME" = "$CHART" ]; then CHART_IN_UNINSTALL_LIST=true; break; fi
done

if [ "$HELM_UNINSTALL" = true ] || [ "$CHART_IN_UNINSTALL_LIST" = true ]; then
    # Uninstall Chart
    bash $SCRIPTS_DIR/helm/helm_uninstall_chart.sh
else
    # Deploy Chart.
    echo "Updating dependencies in '$HELM_CHART_DIRECTORY' ..."
    helm dep up "$HELM_CHART_DIRECTORY"
    bash $SCRIPTS_DIR/helm_deploy_chart.sh
fi

# Run After Deploy Scripts if any.
bash $SCRIPTS_DIR/after-deploy.sh $HELM_CHART_DIRECTORY

printf "${SUCCESS}Helm operation was successful...${NC}\n"


# TODO: do we need this?
# if [ -z "$EXTERNAL_HELM_CHARTS" ]; then 
#     echo "EXTERNAL_HELM_CHARTS directory not set."
# else
#     echo "Running External Helm Charts."
#     bash -x $SCRIPTS_DIR/helm/helm_install_external_charts.sh
# fi

# if [ -z "$HELM_CHARTS_S3" ]; then
#     echo "HELM_CHARTS_S3 not set."
# else
#     echo "Adding S3 Helm Repo."
#     bash -x $SCRIPTS_DIR/helm/helm_install_charts_from_s3.sh 
# fi
