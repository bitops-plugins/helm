#!/usr/bin/env bash
set -e

HELM_CHART="$1"

# passed in
# HELM_CHART_DIRECTORY
# DEFAULT_HELM_CHART_DIRECTORY
# HELM_BITOPS_CONFIG

echo "COPY_DEFAULT_CRDS set..."
if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/crds" ]; then
    echo "default crds/ exists."
    cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/crds/." "$HELM_CHART_DIRECTORY/crds/"
    ls $HELM_CHART_DIRECTORY/crds/
else
    echo "COPY_DEFAULT_CRDS not set"
fi

echo "COPY_DEFAULT_CHARTS set..."
if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/charts" ]; then
    echo "default charts/ exists.\n"
    cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/charts/." "$HELM_CHART_DIRECTORY/charts/"
    ls $HELM_CHART_DIRECTORY/charts/
else
    echo "${ERROR} charts/ does not exist.${NC}\n"
fi


echo "COPY_DEFAULT_TEMPLATES set..."
if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/templates" ]; then
    echo "default templates/ exists.\n"
    cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/templates/." "$HELM_CHART_DIRECTORY/templates/"
    ls $HELM_CHART_DIRECTORY/templates/
else
    echo "${ERROR} templates/ does not exist.${NC}\n"
fi


echo "COPY_DEFAULT_SCHEMA set..."
if [ -d "$DEFAULT_HELM_CHART_DIRECTORY/schema" ]; then
    echo "default schema/ exists.\n"
    cp -rf "$DEFAULT_HELM_CHART_DIRECTORY/schema/." "$HELM_CHART_DIRECTORY/schema/"
    ls $HELM_CHART_DIRECTORY/schema/
else
    echo "${ERROR}  schema/ does not exist.${NC}\n"
fi
