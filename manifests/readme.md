# Kubenetes Manifests

## Kubenetes vs Azure App Service and Azure Postgres Database

If a development team has a desire to keep a simplified architecture I would lean towards using managed cloud services so that the development team can focus on building the app, and leave the infrastructure management to the PaaS service providers. 

However, given the source repo already contains a `Dockerfile` and existing docs contain references that this solution was designed to be containerized, I recommend using Docker and Kubenetes. Teams are far more likely to be highly effective when using tools and services they are already familiar with.

Despite this recommendation, there are several pros and cons which should be discussed with the development team.

- Security: Consider integrated AAD and Managed Identity credentials.
- Performance: Consider managed services are built on highly optimised IOPS and compute specifically designed for the service.
- Scalability: Kubernetes and PaaS are both HA and scalable but are managed differently. 

This bog is a good starting point fot team discussion 
(https://www.codersbistro.com/blog/aks-service-fabric-and-app-service-compared/)

If the team does not currently have strong Docker and Kubenetes skills I would reconsider the use of Azure App Service and Azure Database, however I selected Kubernetes for the initial deployment.

## Planned Architecture

Initially a single node Kubenetes cluster (due to deployment on personal cloud subscription).

The cluster will contain two pods so that the database and app can be scaled independently.

- Postgres Pod
- App Pod


## Postgres Pod

Added below manifests to configure and deploy postgres. Initially hardcoded password but should be replaced with a secret later.

Based on sample templates here https://severalnines.com/database-blog/using-kubernetes-deploy-postgresql


- postgres-config.yml
- postgres-service.yml
- postgres-volumes.yml
- postgres-deployment.yml

## App Pod

Added below manifests to configure and deploy the Go app.

These still use hardcoded references to an Azure Kubernetes Service that need parameterizing in an automated pipeline.

- app-service.yml
- app-deployment.yml
- app-updatedb.yml (once off instance to recreate database and seed data)

---

## Getting Started

### Requirements

Docker and Kubenetes cli
Azure Container Registry with the app image
Update app-deployment.yml with the uri for the app image 

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

```
kubectl describe service techtestapp
```

The `LoadBalancer Ingress` property lists the external IP address.

Open the external `<ip>:3000` in a browser 

#### Debugging

Connect to the Azure Kubenetes service and use kubectl to manually deploy and debug.

If you have PowerShell Core installed you can import the Azure credentials into current session.

``` PowerShell
Import-AzAksCredential -ResourceGroupName <myResourceGroup> -Name <myAKSCluster>
kubectl get nodes
kubectl get pods
kubectl apply -f app-deployment.yml
```