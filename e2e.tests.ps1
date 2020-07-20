<#
Use PowerShell Core to run some basic deployment tests

Install PowerShell Core and `Install-Module -Name Pester -Scope CurrentUser`

Set the $apphost variable to the IP of the app end point / load balancer

Expected output:

Describing TestTechApp with database seed data
  [+] healthcheck should be 'OK' 33ms
  [+] API get task should return seed data 15ms

#>

Import-Module Pester

BeforeAll {
    $apphost='localhost'
    $apphost='13.75.252.87'  
}

Describe 'TestTechApp with database seed data' {
    It "healthcheck should be 'OK'" {
        $response = Invoke-WebRequest -Uri "http://$($apphost):3000/healthcheck/"
        $response.StatusCode | Should -Be 200
        $response.Content | Should -Be 'OK'
    }
    It "API get task should return seed data" {
        $response = Invoke-RestMethod -Uri "http://$($apphost):3000/api/task/" -Method Get
        $response.Count | Should -Be 3
        $response[0].title | Should -Be '1st Task'
    }
}