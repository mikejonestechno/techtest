# Kubenetes Manifests



## Postgres Pod

Added below manifests to configure and deploy postgres. Initially hardcoded password but should be replaced with a secret later.

Based on sample templates here https://severalnines.com/database-blog/using-kubernetes-deploy-postgresql


- postgres-config.yml
- postgres-service.yml
- postgres-volumes.yml
- postgres-deployment.yml

## App Pod

Added below manifests to configure and deploy app

- app-service.yml
- app-deployment.yml

#### Debugging

Connect to the Azure Kubenetes service and use kubectl to manually deploy and debug.

```
Import-AzAksCredential -ResourceGroupName <myResourceGroup> -Name <myAKSCluster>
kubectl get nodes
kubectl get pods
kubectl apply -f app-deployment.yml
```