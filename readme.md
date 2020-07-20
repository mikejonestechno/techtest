# Tech Test Solution

## Overview

This is a simple GTD Golang application that is backed by a Postgres database.

Documentation has been placed in the relevant directories to make it more discoverable, and has been linked below. The documentation could be moved to the `/doc` directory at a later date.

## Architecture

Include ACR and AKS.

Currently defaults to single node and one replica pod (using personal subscription).

## Kubernetes Manifests

Kubernetes manifests are located in `/manifests/` directory.

See the [manifests readme.md](/manifests/readme.md) for more information.

## Azure DevOps Pipeline

to be updated - describe need to parameterize / template the pipeline, and need to plan use of 'environments' and dev/test space.

See the [Azure Pipeline readme azure-pipelines.md](azure-pipelines.md) for more information.

## Tests

Use PowerShell Core to run some basic deployment tests

Install PowerShell Core and `Install-Module -Name Pester -Scope CurrentUser`

Edit `e2e.tests.ps1` and set the $apphost variable to the IP of the app end point / load balancer

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
- Decribe pipeline considerations
  - Currently always rebuilds the app image from scratch regardless of whether app related file has changed, consider splitting pipeline.
- Describe security considerations
  - Currently ACS has -EnableAdmin
  - Postgres is using the default username and pwd
  - Network firewall and access not configured yet (using basic not standard AKS sku)
- Describe performance considerations
  - Currently defaults to single node with one pod, scale properties not configured
