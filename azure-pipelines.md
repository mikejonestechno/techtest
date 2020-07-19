# Azure DevOps Pipelines

## Azure Pipelines vs CircleCI 

The original source project contains a .circleci config to build and package the app files in zip format and tag a github release.

However I dont have access to the CircleCI account so I selected Azure Pipelines to quickly create an automated deployment. 

Ideally I would collaborate with the deveopment team to extend the existing CircleCI pipeline to package the app to a container registry and deploy to a kubenetes service. This would hopefully improve effectiveness by using existing knowledge the team already has, without increasing complexity by adding another tool.

## Prerequisites

A GitHub account, an Azure account, and an Azure DevOps account.

## Initial Setup

I used PowerShell Core and the Az module for initial setup. 

The following PowerShell creates an empty Resource Group with an empty Container Registry and Kubernetes Service.

``` PowerShell
Connect-AzAccount
$rgName = 'myTechTest'
New-AzResourceGroup -Name $rgName -Location 'Australia East'
$acr = New-AzContainerRegistry -ResourceGroupName $rgName -Name "acr$rgName" -EnableAdminUser -Sku Basic
$aks = New-AzAks -ResourceGroupName $rgName -Name "aks$rgname" -NodeCount 1
```

I logged in to Azure DevOps and added a new pipeline for this repo. 

Azure Pipeline automatically built the app container and published it to the container registry.

The original manifests that were automatically generated when the Github repo was added to an Azure Pipeline failed because they default to an out of date schema version :(

```
Error: no matches for kind "Deployment" in version "apps/v1beta1"
```

## Updated Kubenetes Manifests

I replaced the app .yml files on separate pull requests to include the required postgres container and the 'serve' or 'updatedb' arguments.

