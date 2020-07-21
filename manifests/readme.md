# Kubernetes Manifests

## Planned Architecture

In the steps described below Kubernetes is initially created with a single node pool containing two nodes (due to deployment on personal cloud subscription).

The cluster uses two container images so that the database and app can be scaled independently.

- Postgres Pod
- TechTestApp Pod

## Postgres Pods

Added below manifests to configure and deploy postgres. Initially hardcoded password but should be replaced with a secret later.

Based on sample templates here https://severalnines.com/database-blog/using-kubernetes-deploy-postgresql

- postgres-config.yml
- postgres-service.yml
- postgres-volumes.yml
- postgres-deployment.yml

## App Pods

Added below manifests to configure and deploy the TechTest app.

These still use hardcoded references to an Azure Kubernetes Service that need parameterizing in an automated pipeline.

- app-service.yml
- app-deployment.yml
- app-updatedb.yml (once off instance to recreate database and seed data)

The deployment manifest can be modified to include customised horizontal pod scaling under the behaviour section of the spec:

```
behavior:
  scaleDown:
    stabilizationWindowSeconds: 300
    policies:
    - type: Percent
      value: 100
      periodSeconds: 15
  scaleUp:
    stabilizationWindowSeconds: 0
    policies:
    - type: Percent
      value: 100
      periodSeconds: 15
    - type: Pods
      value: 4
      periodSeconds: 15
    selectPolicy: Max
```    

## AKS Storage Volumes

The initial postgres 'local' persistent volumes were modified to use Azure Disks or Azure Files. 

Azure Disks are not highly available, they use the Kubernetes Access Mode 'ReadWriteOnce' and are only available to a single pod in AKS. 

I initially used Azure Files however I encountered the issue reported below that the postgres pod is denied permission to the Azure File volume.
 (https://github.com/Azure/AKS/issues/225)

 ```
 could not change permissions of directory "/var/lib/postgresql/data": Operation not permitted
 ```

As interim solution I used Azure Disk in order to get postgres deployed, but it means the persistent volume is only available to a single pod. Will need to explore alternative options later.

---

## Getting Started

### Requirements

- Docker and Kubernetes kubectl cli
- Azure Container Registry with the pre-built app image
- Updated app-deployment.yml specifying the uri for the container registry

### Manual Deployment

``` bash
kubectl apply -f postgres-config.yml
kubectl apply -f postgres-volumes.yml
kubectl apply -f postgres-service.yml
kubectl apply -f postgres-deployment.yml
kubectl apply -f app-service.yml
kubectl apply -f app-deployment.yml
kubectl apply -f app-updatedb.yml
```

> Note: Postgres needs to be up and running before app-updatedb.

#### Manual Testing

Get the external IP for the app to test the deployment was successful.

```
kubectl describe service techtestapp
```

The `LoadBalancer Ingress` property lists the external IP address.

Open the external `<ip>:3000` in a browser. 

Check the `<ip>:3000/healthcheck/` displays the content `'OK'`.

#### Debugging

Connect to the Azure Kubernetes service and use kubectl to manually deploy and debug.

If you have PowerShell Core installed you can import the Azure credentials into current session.

``` PowerShell
Import-AzAksCredential -ResourceGroupName <myResourceGroup> -Name <myAKSCluster>
kubectl get nodes
kubectl get pods
kubectl apply -f app-deployment.yml
```

Visual Studio Code also has a very useful Kubernetes extension for browsing all the cluster resources and their properties.

#### Azure Pipeline Manifests (initial version)

Azure Pipeline automatically generated some Kubernetes manifests when the Github repo was used to create a new Azure Pipeline. The manifests failed because they default to an out of date schema version :(

```
error: unable to recognize "/home/vsts/work/_temp/Deployment_mikejonestechnotechtest_1595126652252": no matches for kind "Deployment" in version "apps/v1beta1"
```

This was resolved by replacing the manifests with working versions described above.