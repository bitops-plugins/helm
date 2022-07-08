#!/usr/bin/env bash
set -e

# helm cli vars
export NAMESPACE="$BITOPS_NAMESPACE"
export TIMEOUT="$BITOPS_HELM_TIMEOUT"
export HELM_SET_FLAG="$BITOPS_HELM_SET_FLAG"
export HELM_DEBUG="$BITOPS_HELM_DEBUG"
export ATOMIC="$BITOPS_HELM_ATOMIC"
export FORCE="$BITOPS_HELM_FORCE"
export DRY_RUN="$BITOPS_HELM_DRY_RUN"

# helm option vars
export HELM_SKIP_DEPLOY="$BITOPS_HELM_SKIP_DEPLOY"
export HELM_RELEASE_NAME="$BITOPS_HELM_RELEASE_NAME"
export DEFAULT_SUB_DIR="$BITOPS_ENVROOT/$BITOPS_DEFAULT_ROOT_DIR/helm/$BITOPS_DEFAULT_SUB_DIR"
# export DEFAULT_HELM_ROOT="$BITOPS_ENVROOT/$BITOPS_DEFAULT_ROOT_DIR"
export DEFAULT_DIR_FLAG="$BITOPS_DEFAULT_DIR_FLAG"
export PLUGINS_ROOT_DIR="$BITOPS_PLUGINS_DIR"
export HELM_ROOT_SCRIPTS="$BITOPS_PLUGIN_DIR"
export HELM_ROOT_OPERATIONS="$BITOPS_OPSREPO_ENVIRONMENT_DIR"
export ENVIRONMENT="$BITOPS_ENVIRONMENT"
export ENV_DIR="$BITOPS_ENVROOT"
export ENVIRONMENT_HELM_SUBDIRECTORY="$BITOPS_ENVIRONMENT_HELM_SUBDIRECTORY"


export HELM_RELEASE_NAME=""
export HELM_DEBUG_COMMAND=""
export HELM_DEPLOY=${HELM_CHARTS:=false}


if [ -n "$HELM_SKIP_DEPLOY" ]; then
  echo "HELM_SKIP_DEPLOY set...Skipping deployment for $ENVIRONMENT/helm/$HELM_CHART"
  exit 0
else
  echo "calling helm/deploy ..."
  # if subdirectory is not provided, iterate subdirectories
  if [ -z "$ENVIRONMENT_HELM_SUBDIRECTORY" ]; then
    echo "ENVIRONMENT_HELM_SUBDIRECTORY not provided, iterate all helm charts in $ENV_DIR/helm"
    for helm_chart_dir in $HELM_ROOT_OPERATIONS/*/; do
      helm_chart_dir=${helm_chart_dir%*/}     # remove the trailing "/"
      helm_chart_dir=${helm_chart_dir##*/}    # get everything after the final "/"
      echo "Deploy $helm_chart_dir for $ENVIRONMENT"
      export BITOPS_SCHEMA_ENV_FILE="$BITOPS_OPSREPO_ENVIRONMENT_DIR/$helm_chart_dir/ENV_FILE"
      export BITOPS_PLUGIN_SCHEMA_DIR="$BITOPS_PLUGIN_DIR/bitops.schema.yaml"
      export HELM_CONFIG_SCRIPTS_DIR="$BITOPS_PLUGIN_DIR/config"
      export BITOPS_OPSREPO_CONFIG_FILE_PATH="$BITOPS_OPSREPO_ENVIRONMENT_DIR/$helm_chart_dir/bitops.config.yaml"
      export BITOPS_CONFIG_COMMAND="$(ENV_FILE="$BITOPS_SCHEMA_ENV_FILE" DEBUG="" bash $HELM_CONFIG_SCRIPTS_DIR/convert-schema.sh $BITOPS_PLUGIN_SCHEMA_DIR $BITOPS_OPSREPO_CONFIG_FILE_PATH)"
      echo "BITOPS_CONFIG_COMMAND: $BITOPS_CONFIG_COMMAND"
      source "$BITOPS_SCHEMA_ENV_FILE"

      # Check for Before Deploy Scripts
      # bash $SCRIPTS_DIR/deploy/before-deploy.sh "$HELM_CHART_DIRECTORY"
      printenv
      # $HELM_ROOT_SCRIPTS/scripts/helm_handle_chart.sh $helm_chart_dir
    done
  else
    echo "ENVIRONMENT_HELM_SUBDIRECTORY: $ENV_DIR/helm/$ENVIRONMENT_HELM_SUBDIRECTORY"
    # $PLUGINS_DIR/helm/scripts/helm_handle_chart.sh $ENVIRONMENT_HELM_SUBDIRECTORY
  fi
fi

