# Azure DevOps Pipelines

## Azure Pipelines vs CircleCI 

The original source project contains a .circleci config to build and package the app files in zip format and tag a github release.

However I dont have access to the CircleCI account so I selected Azure Pipelines to quickly create an automated deployment. 

Ideally I would collaborate with the deveopment team to extend the existing CircleCI pipeline to package the app to a container registry and deploy to a kubenetes service. This would hopefully improve effectiveness by using existing knowledge the team already has, without increasing complexity by adding another tool.

## Prerequisites

A GitHub account, an Azure account, and an Azure DevOps account.

## Initial Automated Setup

I used PowerShell Core and the Az module for initial setup. 

The following PowerShell creates an empty Resource Group with an empty Container Registry and Kubernetes Service.

``` PowerShell
Connect-AzAccount
$rgName = 'myTechTest'
New-AzResourceGroup -Name $rgName -Location 'Australia East'
$acr = New-AzContainerRegistry -ResourceGroupName $rgName -Name "acr$rgName" -EnableAdminUser -Sku Basic
$aks = New-AzAks -ResourceGroupName $rgName -Name "aks$rgname" -NodeCount 1
```

I logged in to Azure DevOps and added a new pipeline for this *freshly cloned* repo (before any containers or yml files were checked in). 

Azure Pipeline automatically built the app container and published it to the container registry.

Azure Pipeline automatically generated kubernetes manifests and attempted to deploy to AKS cluster however the automatically generated manifests failed because they default to an out of date schema version :(

```
Error: no matches for kind "Deployment" in version "apps/v1beta1"
```

I put this branch on hold while creating replacement manifest .yml files on separate pull requests. 

## Updated Kubenetes Manifests

Having added new manifests that include the required postgres container and include the 'serve' or 'updatedb' arguments, I returned to this branch to update the automated deployment.

The automatically generated azure-pipelines.yml itself is missing the mandatory kubernetesServiceConnection property that is required on the current version of the Kubernetes manifest task. 

> I guess Microsoft are moving too fast to keep their automated devops generation up to date. Too bad, it used to (almost) be a one click setup. :(

## AKS Storage Volumes

The postgres 'local' persistent volumes need to me modified to Azure Disk or Azure Files. 

I initially used Azure Files because Azure Disk uses Access Mode 'ReadWriteOnce' and is only available to a single pod in AKS. 

However I encountered issue reported below that the postgres pod is denied permission to the Azure File volume.
 https://github.com/Azure/AKS/issues/225

 ```
 could not change permissions of directory "/var/lib/postgresql/data": Operation not permitted
 ```

As interim solution I used Azure Disk in order to get postgres deployed, but it means the persistent volume is only available to a single pod. Will need to explore alternative options later.


