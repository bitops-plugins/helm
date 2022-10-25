#!/usr/bin/env bash
set -e

if [ -n "$SKIP_DEPLOY_HELM" ]; then
  echo "SKIP_DEPLOY_HELM is set.  Skipping."
  exit 0
fi

export PLUGINS_ROOT_DIR="${BITOPS_PLUGINS_DIR%/*}"
export HELM_ROOT_SCRIPTS="$BITOPS_PLUGIN_DIR"
export HELM_ROOT_OPERATIONS="$BITOPS_OPSREPO_ENVIRONMENT_DIR"
export ENVIRONMENT="$BITOPS_ENVIRONMENT"
export ENV_DIR="$BITOPS_ENVROOT"
export ENVIRONMENT_HELM_SUBDIRECTORY="$BITOPS_ENVIRONMENT_HELM_SUBDIRECTORY"


export HELM_RELEASE_NAME=""
export HELM_DEBUG_COMMAND=""
export HELM_DEPLOY=${HELM_CHARTS:=false}


echo "calling helm/deploy ..."
# if subdirectory is not provided, iterate subdirectories
if [ -z "$ENVIRONMENT_HELM_SUBDIRECTORY" ]; then
  echo "ENVIRONMENT_HELM_SUBDIRECTORY not provided, iterate all helm charts in $ENV_DIR/helm"
  for helm_chart_dir in $HELM_ROOT_OPERATIONS/*/; do
    helm_chart_dir=${helm_chart_dir%*/}     # remove the trailing "/"
    helm_chart_dir=${helm_chart_dir##*/}    # get everything after the final "/"
    echo "Deploy $helm_chart_dir for $ENVIRONMENT"
    
    $HELM_ROOT_SCRIPTS/scripts/helm_handle_chart.sh $helm_chart_dir

  done
else
  echo "ENVIRONMENT_HELM_SUBDIRECTORY: $ENVIRONMENT_HELM_SUBDIRECTORY"
  echo "ENVIRONMENT_HELM_SUBDIRECTORY full path: $HELM_ROOT_OPERATIONS/$ENVIRONMENT_HELM_SUBDIRECTORY"
  $HELM_ROOT_SCRIPTS/scripts/helm_handle_chart.sh $ENVIRONMENT_HELM_SUBDIRECTORY
fi