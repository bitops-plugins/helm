#!/usr/bin/env bash
set -e

# export BITOPS_FAST_FAIL="true"
# export BITOPS_MODE="default"
# export BITOPS_LOGGING_LEVEL="DEBUG"
# export BITOPS_logging_color="False"
# export BITOPS_logging_path="/Users/srayaprolu/Documents/Shyam-Work/CloudApplications-Development/BiTOVi/local-testing/bitopsv2-operations-repos/logs"
# export BITOPS_DEFAULT_FOLDER_NAME="_default"
# export BITOPS_TIMEOUT="600"
# export BITOPS_DIR="/Users/srayaprolu/Documents/Shyam-Work/CloudApplications-Development/BiTOVi/Github/bitops"
# export BITOPS_PLUGIN_DIR="/Users/srayaprolu/Documents/Shyam-Work/CloudApplications-Development/BiTOVi/Github/bitops-plugins/helm"
# export BITOPS_SCRIPTS_DIR="/Users/srayaprolu/Documents/Shyam-Work/CloudApplications-Development/BiTOVi/Github/bitops/scripts"
# export BITOPS_OPSREPO_ENVIRONMENT_DIR="/Users/srayaprolu/Documents/Shyam-Work/CloudApplications-Development/BiTOVi/local-testing/bitopsv2-operations-repos/opsrepo-deployments-poc/helm"
export BITOPS_SCHEMA_FILE_PATH="$BITOPS_PLUGIN_DIR/bitops.schema.yaml"
export BITOPS_BUILD_CONFIG_YAML="$BITOPS_DIR/bitops.config.yaml"
export BITOPS_OPSREPO_CONFIG_FILE_PATH="$BITOPS_OPSREPO_ENVIRONMENT_DIR/nginx-ingress/bitops.config.yaml"
export BITOPS_UTIL_SCRIPT="$BITOPS_SCRIPTS_DIR/plugins.py"

# /utilities.py

# chmod +x $BITOPS_UTIL_SCRIPT

# RESULT=`python3 -c 'import $BITOPS_PARSE_SCRIPT; print(main.returnHelloWorld())'`
RESULT=`python3 $BITOPS_UTIL_SCRIPT "schema_parsing" $BITOPS_OPSREPO_CONFIG_FILE_PATH $BITOPS_SCHEMA_FILE_PATH`
echo $RESULT
echo "=================================="
printenv '%s\n' 'aa\nbb' | awk  '{gsub("\\\\n","\n")};1'

#helm cli vars
# export NAMESPACE="$BITOPS_NAMESPACE"
# export TIMEOUT="$BITOPS_TIMEOUT"
# export HELM_SET_FLAG="$BITOPS_HELM_SET_FLAG"
# export HELM_DEBUG="$BITOPS_HELM_DEBUG"
# export ATOMIC="$BITOPS_ATOMIC"
# export FORCE="$BITOPS_FORCE"
# export DRY_RUN="$BITOPS_DRY_RUN"
# export bitops_scripts_dir="$BITOPS_SCRIPTS_DIR"

# helm option vars
# export HELM_SKIP_DEPLOY="$BITOPS_HELM_SKIP_DEPLOY"
# export HELM_RELEASE_NAME="$BITOPS_HELM_RELEASE_NAME"
# export DEFAULT_SUB_DIR="$BITOPS_ENVROOT/$BITOPS_DEFAULT_ROOT_DIR/helm/$BITOPS_DEFAULT_SUB_DIR"
# export DEFAULT_HELM_ROOT="$BITOPS_ENVROOT/$BITOPS_DEFAULT_ROOT_DIR"
# export DEFAULT_DIR_FLAG="$BITOPS_DEFAULT_DIR_FLAG"
# export PLUGINS_ROOT_DIR="$BITOPS_PLUGINS_DIR"
# export HELM_ROOT_SCRIPTS="$BITOPS_PLUGIN_DIR"
# export HELM_ROOT_OPERATIONS="$BITOPS_OPSREPO_ENVIRONMENT_DIR"
# export ENVIRONMENT="$BITOPS_ENVIRONMENT"
# export ENV_DIR="$BITOPS_ENVROOT"
# export ENVIRONMENT_HELM_SUBDIRECTORY="$BITOPS_ENVIRONMENT_HELM_SUBDIRECTORY"

# export HELM_RELEASE_NAME=""
# export HELM_DEBUG_COMMAND=""
# export HELM_DEPLOY=${HELM_CHARTS:=false}


# if [ -n "$HELM_SKIP_DEPLOY" ]; then
#   echo "HELM_SKIP_DEPLOY set...Skipping deployment for $ENVIRONMENT/helm/$HELM_CHART"
#   exit 0
# else
#   echo "calling helm/deploy ..."
#   # if subdirectory is not provided, iterate subdirectories
#   if [ -z "$ENVIRONMENT_HELM_SUBDIRECTORY" ]; then
#     echo "ENVIRONMENT_HELM_SUBDIRECTORY not provided, iterate all helm charts in $ENV_DIR/helm"
#     for helm_chart_dir in $HELM_ROOT_OPERATIONS/*/; do
#       helm_chart_dir=${helm_chart_dir%*/}     # remove the trailing "/"
#       helm_chart_dir=${helm_chart_dir##*/}    # get everything after the final "/"
#       echo "Deploy $helm_chart_dir for $ENVIRONMENT"
#       # $HELM_ROOT_SCRIPTS/scripts/helm_handle_chart.sh $helm_chart_dir
#     done
#   else
#     echo "ENVIRONMENT_HELM_SUBDIRECTORY: $ENV_DIR/helm/$ENVIRONMENT_HELM_SUBDIRECTORY"
#     # $PLUGINS_DIR/helm/scripts/helm_handle_chart.sh $ENVIRONMENT_HELM_SUBDIRECTORY
#   fi
# fi

