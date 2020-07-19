# Kubenetes Manifests

These original manifests were automatically generated when the Github repo was added to an Azure Pipeline. 

The inital pipeline deployment task failed and needs debugging.

```
/usr/bin/kubectl apply -f /home/vsts/work/_temp/Deployment_mikejonestechnotechtest_1595126652252,/home/vsts/work/_temp/Service_mikejonestechnotechtest_1595126652253 --namespace default
error: unable to recognize "/home/vsts/work/_temp/Deployment_mikejonestechnotechtest_1595126652252": no matches for kind "Deployment" in version "apps/v1beta1"
service/mikejonestechnotechtest created
##[error]error: unable to recognize "/home/vsts/work/_temp/Deployment_mikejonestechnotechtest_1595126652252": no matches for kind "Deployment" in version "apps/v1beta1"
```