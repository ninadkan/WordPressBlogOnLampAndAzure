. "$PSScriptRoot\login.ps1"

$publicIp = Get-AzPublicIpAddress `
    -Name $publicIpName `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -ErrorAction SilentlyContinue

if ($publicIp)
{
    Remove-AzPublicIpAddress `
        -Name $publicIpName `
        -ResourceGroupName $RESOURCEGROUP_NAME 
}


