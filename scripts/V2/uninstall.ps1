. "$PSScriptRoot\login.ps1"

Write-Host "------------ STARTING REMOVAL      ----------------------------"
Write-Host "---------------------------------------------------------------"

. "$PSScriptRoot\6-detach-remove-temporaryIPaddress.ps1"

Write-Host "----------------------   5         ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\5-remove-VM.ps1"

Write-Host "----------------------   4         ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\4-remove-nw-interfaces-load-balancer.ps1"

Write-Host "----------------------   3         ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\3-remove-availability-set-storage.ps1"

Write-Host "----------------------   2         ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\2-remove-network.ps1"

Write-Host "----------------------   1         ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\1-remove-public-IP-connect-DNS.ps1"


Write-Host "-------------- DONE   REMOVAL      ----------------------------"
Write-Host "---------------------------------------------------------------"





