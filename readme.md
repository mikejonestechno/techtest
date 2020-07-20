# Tech Test Solution

## Overview

This is a simple GTD Golang application that is backed by a Postgres database.

## Architecture

to be updated

Currently defaults to single node and one replica pod (using personal subscription).

## Kubernetes Manifests

Kubernetes manifests are located in `/manifests/` directory.

See the [manifests readme.md](/manifests/readme.md) for more information.

## Azure DevOps Pipeline

to be updated

See the [Azure Pipeline readme azure-pipelines.md](azure-pipelines.md) for more information.

## Tests

Use PowerShell Core to run some basic deployment tests

Install PowerShell Core and `Install-Module -Name Pester -Scope CurrentUser`

Set the $apphost variable to the IP of the app end point / load balancer

Expected output:

```
Describing TestTechApp with database seed data
  [+] healthcheck should be 'OK' 33ms
  [+] API get task should return seed data 15ms
```

## Next Steps

- Add updatedb to the deployment to create and seed the data
- Update all references for a clean install in new subscription / devops project
- Describe architecture considerations
  - Currently one Azure Devops environment, need discussion with team about use of dev/test environments
- Describe security considerations
  - Currently ACS has -EnableAdmin
  - Postgres is using the default username and pwd
  - Network firewall and access not configured yet (using basic not standard AKS sku)
- Describe performance considerations
  - Currently defaults to single node with one pod, scale properties not configured
