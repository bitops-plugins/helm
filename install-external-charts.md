## HELM External Charts Deployment

*Helm external charts can be installed using umbrella charts concept of helm which allows the provisioning of sub-charts through the parent-child mechanism. A child chart placed in the the charts folder in Helm can be deployed by declaring the sub-chart in the parent’s `Chart.yaml` file.*
#### Instructions for Helm Umbrella Chart Creation

* Create a new Helm Chart 
    ```
    helm create bitops-nginx
    ```
* Leave `Chart.yaml` and `values.yaml` files and delete rest all files and folders in the newly created "bitops-nginx" helm chart
* Now update the `Chart.yaml` with nginx subchart as a dependency

    ```
    apiVersion: v2
    name: nginx chart wrapper
    description: A Helm chart wrapper for nginx
    version: 0.1.0

    dependencies:
    - name: bitops-nginx
    version: <nginx chart version from above>
    repository: <artifact repo url>

    ```
* Now update the `values.yaml` with nginx subchart values
    ```
    Note: Make sure all nginx subchart values are under the `Chart.yaml` dependency name "bitops-nginx". Check below for the example
    ```
    ```
    bitops-nginx:
        replicas: 1
    ```