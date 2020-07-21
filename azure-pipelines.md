# Azure DevOps Pipelines

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



## Update database and seed data

The app image is deployed to a temporary container to run the `-updatedb` command to create the database and seed data. 

The series of steps in the pipeline will need to be reviewed later, particularly when production environment is added, to ensure production data is not wiped with future database changes! 

The separation of pods could also be modified later and the development team may also want to review alternative methods to manage and maintain database changes in the future.