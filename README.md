# Bitops Plugin for Helm

## Introduction
This plugin will let BitOps to automatically deploy ``helm`` templates to kubernates running on any provider. 

## Installation

This plugin gets installed through ```bitops.config.yaml```.

### Sample Config

```
bitops:
  fail_fast: true 
  run_mode: default
  logging:      
    level: DEBUG
    color:
      enabled: true
    filename: bitops-run
    err: bitops.logs
    path: /var/logs/bitops
  opsrepo_root_default_dir: _default
  plugins:    
    helm:
      source: https://github.com/bitops-plugins/helm
...
...
...

```

## Deployment

``helm`` plugin uses ```bitops.config.yaml``` located in the operations repo when deploying resources using helm templates.

### Sample Config
```
helm:
  cli:
    namespace: bitops
    timeout: 60s
    set:
     - "key1=value1"
     - "key2=value2"
    debug: false
    atomic: true
    force: true
    dry-run: true
  options:
    skip-deploy: false
    release-name: bitops-release
    uninstall-charts: "chart1,chart2"
    aws:
      fetch:
        kubeconfig: true
        cluster-name: my-cluster
  plugins:
```

This version of ``helm`` plugin loops over the list of all helm chart folders of the operations repo and install in a sequential manner.

However if a helm chart folder name is passed in ``BITOPS_ENVIRONMENT_HELM_SUBDIRECTORY`` variable in the docker run, this plugin will only install that specific helm chart. Below is the sample docker run showing how to install only one helm chart.

```
docker run --rm --name bitops \
-e AWS_ACCESS_KEY_ID="${BITOPS_AWS_ACCESS_KEY_ID}" \
-e AWS_SECRET_ACCESS_KEY="${BITOPS_AWS_SECRET_ACCESS_KEY}" \
-e AWS_DEFAULT_REGION="${BITOPS_AWS_DEFAULT_REGION}" \
-e BITOPS_ENVIRONMENT="${ENVIRONMENT}" \
-e BITOPS_ENVIRONMENT_HELM_SUBDIRECTORY="ingress-nginx"  \
-v $(pwd):/opt/bitops_deployment \
bitops-core:latest

```

## CLI and options configuration of helm ``bitops.schema.yaml``

### Helm BitOps Schema

```
helm:
  type: object
  properties:
    cli:
      type: object
      properties:
        namespace:
          type: string
          parameter: namespace
          export_env: NAMESPACE
          required: true
        timeout:
          type: string
          parameter: timeout
          export_env: TIMEOUT
          default: "500s"
        set:
          type: list
          parameter: set
          export_env: HELM_SET_FLAG
        debug:
          type: boolean
          parameter: debug
          export_env: HELM_DEBUG
        atomic:
          type: boolean
          parameter: atomic
        force:
          type: boolean
          parameter: force
        dry-run:
          type: boolean
          parameter: dry-run
    options:
      type: object
      properties:
        skip-deploy:
          type: boolean
          parameter: skip-deploy
          export_env: HELM_SKIP_DEPLOY
        release-name:
          type: string
          export_env: HELM_RELEASE_NAME
        default-root-dir:
          type: string
          export_env: DEFAULT_ROOT_DIR
        default-dir-flag:
          type: boolean
          default: true
          export_env: DEFAULT_DIR_FLAG
        default-sub-dir:
          type: string
          export_env: DEFAULT_SUB_DIR
        uninstall:
          type: string
          export_env: HELM_UNINSTALL
        aws:
          type: object
          properties:
            kubeconfigpath:
              type: string
              export_env: KUBE_CONFIG_PATH
            fetch:
              type: object
              properties:
                kubeconfig: 
                  type: boolean
                  default: true
                  export_env: FETCH_KUBECONFIG
                cluster-name:
                  type: string
                  export_env: CLUSTER_NAME
        
    plugins:
      type: object
      properties:
        s3:
          type: object
          properties:
            region:
              type: string
              export_env: HELM_PLUGIN_S3_REGION
            bucket:
              type: string
              export_env: HELM_CHARTS_S3_BUCKET

```
-------------------
### namespace
* **BitOps Property:** `namespace`
* **Environment Variable:** `NAMESPACE`
* **default:** `""`
* **required:** yes

namespace scope for this request

-------------------
### timeout
* **BitOps Property:** `timeout`
* **Environment Variable:** `TIMEOUT`
* **default:** `"500s"`

time to wait for any individual Kubernetes operation (like Jobs for hooks) 

-------------------
### set
* **BitOps Property:** `set`
* **Environment Variable:** `HELM_SET_FLAG`
* **default:** `{}`

list of "key=value" strings to pass in to `helm` via `--set`

-------------------
### debug
* **BitOps Property:** `debug`
* **Environment Variable:** `HELM_DEBUG`
* **default:** `""`

enable verbose helm output

-------------------
### atomic
* **BitOps Property:** `atomic`
* **Environment Variable:** `TODO`
* **default:** `""`

if set, the installation process deletes the installation on failure

-------------------
### force
* **BitOps Property:** `force`
* **Environment Variable:** `TODO`
* **default:** `""`

sets helm's `--force` flag

-------------------
### dry-run
* **BitOps Property:** `dry-run`
* **Environment Variable:** `TODO`
* **default:** `""`

simulate an install

-------------------
## Options Configuration

-------------------
### skip-deploy
* **BitOps Property:** `skip-deploy`
* **Environment Variable:** `SKIP_DEPLOY`
* **default:** `""`

will skip helm execution

-------------------
### release-name
* **BitOps Property:** `release-name`
* **Environment Variable:** `HELM_RELEASE_NAME`
* **default:** `""`

sets helm release name

-------------------
### uninstall
* **BitOps Property:** `uninstall`
* **Environment Variable:** `HELM_UNINSTALL`
* **default:** `""`

If true, this chart will be uninstalled instead of deployed/upgraded. If the environment variable `HELM_UNINSTALL` is passed in to the container, all BitOps managed charts for a given environment will be uninstalled.

-------------------
### kubeconfig
* **BitOps Property:** `aws`

configure cluster access. Has the following child-properties. Should provide one of `aws.kubeconfigpath` or `aws.fetch.kubeconfig & aws.fetch.cluster-name`. Defaults to ``aws.fetch.kubeconfig & aws.fetch.cluster-name``

### path
* **BitOps Property:** `aws.kubeconfigpath`
* **Environment Variable:** `KUBE_CONFIG_PATH`
* **default:** `""`

relative file path to .kubeconfig file

#### fetch
* **BitOps Property:** `aws.fetch`

aws.fetch kubeconfig using cloud provider auth

##### enabled
* **BitOps Property:** `aws.fetch.kubeconfig`
* **Environment Variable:** `FETCH_KUBECONFIG`
* **default:** `true`

enables/disables aws.fetch

##### cluster-name
* **BitOps Property:** `aws.fetch.cluster-name`
* **Environment Variable:** `CLUSTER_NAME`
* **default:** `""`

cloud kubernetes cluster name for kubeconfig fetching.

-------------------
## Plugin Configuration
This section of `bitops.config.yml` is unique to helm and allows the customization of helm plugins

-------------------
### S3 Plugin
* **BitOps Property:** `s3`

Configure [helm s3 plugin](https://github.com/hypnoglow/helm-s3) with the following properties

-------------------
#### region
* **BitOps Property:** `s3.region`
* **Environment Variable:** `HELM_PLUGIN_S3_REGION`

AWS region containing s3 bucket

-------------------
#### bucket
* **BitOps Property:** `s3.bucket`
* **Environment Variable:** `HELM_CHARTS_S3_BUCKET`

AWS s3 bucket name

-------------------
## Additional Environment Variable Configuration
Although not captured in `bitops.config.yml`, the following environment variables can be set to further customize behaviour

-------------------
### SKIP_DEPLOY_HELM
Will skill all helm executions. This superseeds all other configuration

-------------------
### HELM_UNINSTALL_CHARTS
Comma separated string. If any of the charts to be deployed match one of the chart names listed here, it will be uninstalled with `helm uninstall $HELM_RELEASE_NAME` instead of deployed/upgraded.


