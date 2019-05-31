. "$PSScriptRoot\login.ps1"

Write-Host "------------ STARTING REMOVAL      ----------------------------"
Write-Host "---------------------------------------------------------------"

. "$PSScriptRoot\1-create-public-IP-connect-DNS.ps1"

Write-Host "--------------------------   1     ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\2-create-network.ps1"

Write-Host "--------------------------   2     ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\3-create-availability-set-storage.ps1"

Write-Host "--------------------------   3     ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\4-create-nw-interfaces-load-balancer.ps1"

Write-Host "--------------------------   4     ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\5-create-VM.ps1"

Write-Host "--------------------------   5     ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\6-create-attach-temporary-publicIP.ps1"

Write-Host "--------------------------   6     ----------------------------"
Write-Host "---------------------------------------------------------------"
. "$PSScriptRoot\8-linux-scripts.ps1"

Write-Host "---------------------------------------------------------------"
Write-Host "Now login to the backend database server to install database"
Write-Host "Files related to that installation is in .\dbserver directory "

Write-Host "Next install the Apache+PHP+WordPress on the front press server"
Write-Host "Make '.\webserver' the current working directory"
Write-Host "Execute the command scopy.bat"

Write-Host "Now open browser, navigate to the blogs website"
Write-Host "Complete the installation of the WordPress from the Browser"
Write-Host "------------ DONE -----------------------------------------"













