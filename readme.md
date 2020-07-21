# Tech Test Solution

## Overview

This is a simple GTD Golang application that is backed by a Postgres database.

## Architecture

The application is packaged as a Docker image to Azure Container Registry and deployed to an Azure Kubernetes Service.

By default Azure Kubernetes Service uses a VM Availability Set to spread the Kubernetes nodes across 2 fault domains and 3 update domains in the selected Azure region making the solution reasonably robust.

The Kubernetes behaviour can be specified to automatically scale up and down across mulitple pods.

The initial deployment will host the application in a 'test' namespace on a 3 replica pod across 2 nodes in a single node pool. After validation of the solution architecture using this basic SKU the cluster may be recreated on a Standard SKU supporting multiple node pools.

An Azure DevOps pipeline is used to automatically build the image and deploy to Kubernetes. A pipeline environment is used to monitor and trace deployment history to the cluster.

## Known Issues

The solution does not contain any automated tests. Automated deployments will result in untested buggy code being pushed to a production environment. A basic end to end deployment test has been added in order to test the health check and seed data appears in the application. Test strategy and approach needs to be discussed with the development team.

The Azure Kubernetes Service extension 'Local Process' (previously known as Dev Spaces) allows a remote process debugging experience as if running a local Kubernetes instance. The local process feature is currently in public preview and has not been configured for the solution yet. Developer and Tester experience should be discussed with the team.
https://code.visualstudio.com/docs/containers/local-process-kubernetes
https://docs.microsoft.com/en-us/azure/dev-spaces/

The AKS Deployment Center feature and AKS Policies feature are also in public preview and have not been configured. While the wider Azure Policies are a GA service,the AKS Policies feature is still in preview and requires signing up with Microsoft to register for the preview.

The current Kubernetes persistent volume uses Azure Disks and postgres is thus restricted to a single postgres pod. The alternative Azure Files volumes support the Kubernetes ReadWriteMany access mode however further work is needed to workaround the postgres permission setup issue with Azure Files. 

Azure Monitor Insights, Azure Alerts and Azure Log Analytics have not been configured yet. These require a Log Analytics workspace and can easily be added later after validation of the solution architecture.




Azure DevOps pipeline environments provide basic monitoring and dev/test/prod traceability with the deployments and change commits.

- security
- other

## Kubernetes Manifests

Kubernetes manifests are located in `/manifests/` directory.

See the [manifests readme.md](/manifests/readme.md) for more information.

## Azure DevOps Pipeline

to be updated

See the [Azure Pipeline readme azure-pipelines.md](azure-pipelines.md) for more information.

## Getting Started

to be updated

Follow the steps below to get the solution deployed to a clean Azure subscription using a clean Azure Devops project.

### Azure Setup

Create a new Azure Resource group with an Azure Container Registry and an Azure Kubernetes Service using the Azure portal, Azure CLI or PowerShell Core (with Az module installed).

!!! check if -EnableAdminUser is required !!!
I think its needed for the admin secrets to pass in to AKS to pull the images, otherwise need to configure kubernetes managed identity and give it access to the ACS. below link has steps
https://azuredevopslabs.com/labs/vstsextend/kubernetes/
https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks
The pipeline may also need service principal / service endpoint for the docker task (this sample uses classic pipeline not yaml)
https://docs.microsoft.com/en-us/azure/devops/pipelines/library/connect-to-azure?view=vsts

For production the standard or premium skus should be used which support network firewall rules and additional scaling options. 

The following PowerShell creates a basic container registry and a Kubernetes node pool containing 2 small VMs suitable for use on a personal subscription account.

The creation of ACR and AKS could be automated via ARM template or other tool such as Terraform. This is a once only setup and needs to be completed before creating the Azure DevOps service connections below.

```
Connect-AzAccount

$rgName = 'TechTest'
New-AzResourceGroup -Name $rgName -Location 'Australia East'
$acr = New-AzContainerRegistry -ResourceGroupName $rgName -Name "acr$rgName" -EnableAdminUser -Sku Basic
$aks = New-AzAks -ResourceGroupName $rgName -Name "aks$rgname" -NodeVMSize Standard_B2s -NodeCount 2
```

> Note: The Container Registry variable in the azure-pipeline.yml must match the ACR server name created above e.g. 'acrtechtest.azurecr.io'.

### Azure DevOps Project Setup

Login to Azure Devops `https://dev.azure.com/<myaccount>`.

Create a new Azure DevOps project using the '+ New Project' button top right of screen. Accept the default values for Git version control and Work Item process.

Go to Pipelines > Environments.

Create a new environment named 'TechTest-test' (this will be the test environment rather than -prod environment).

Select the Kubernetes resource, and select your 'aksTechTest' resource created above.

Create a new namespace called 'test' and click 'Validate and create'.

This creates an Azure DevOps environment and namespace that can be isolated from the future production cluster.

Go to project settings `https://dev.azure.com/<myaccount>/<myproject>/_settings/`.

Select 'Service connections' under the 'Pipelines' heading.

Create a new service connection, selecting the 'Docker Registry' type and click 'Next'. 

Set the Registry Type = 'Azure Container Registry' and select your 'acrTechTest' resource created above.

Name this service connection 'ACRTechTest' and Save the connection.

Create a seconds service connection, selecting the 'Kubernetes' type and click 'Next'.

Set the Authentication Method = 'Azure Subscription' and select your 'aksTechTest' resource created above.

Select the 'test' namespace, name this service connection 'AKSTechTest-test' and Save the connection.

### Azure Pipeline

Check the azure-pipelines.yml variables match the names of the service connections created above.

Go to the Azure DevOps build pipelines page `https://dev.azure.com/<myaccount>/<myproject>/_build`.

Create a pipeline, and select this GitHub repo. 

Save and run the pipeline. 

## Tests

After a successful deployment, use PowerShell Core to run some basic deployment tests.

Install PowerShell Core and `Install-Module -Name Pester -Scope CurrentUser`.

Edit `e2e.tests.ps1` and set the $apphost variable to the IP of the app end point / load balancer.

Run `Invoke-Pester -Output Detailed` or run the tests in `/e2e.tests.ps1` using VS Code. 

Expected output:

```
Describing TestTechApp with database seed data
  [+] healthcheck should be 'OK' 33ms
  [+] API get task should return seed data 15ms
```

## Next Steps

- Update all references for a clean install in new subscription / devops project
- Describe architecture considerations
  - Currently one Azure Devops environment, need discussion with team about use of dev/test environments
- Describe security considerations
  - Currently ACS has -EnableAdmin
  - Postgres is using the default username and pwd
  - Network firewall and access not configured yet (using basic not standard AKS sku)
- Describe monitoring considerations
  - Currently only out-of-the-box Azure monitoring, App Insights / Azure Monitor alerts have not been configured.
- Describe performance considerations
  - Currently defaults to single node with one pod, scale properties not configured
