#Delete mapped hostname in Azure 
. "$PSScriptRoot\login.ps1"

# assumes that the web app is already created and is configured correctly in the DNS records of the DNS provider
$WebAppInfo = Get-AzureRmWebApp -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_APPNAME


if ($WebAppInfo.HostNames.Contains($FQDN))
{
    $WebAppInfo.HostNames.Remove($FQDN)
    Set-AzureRmWebApp -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_APPNAME -HostNames $WebAppInfo.HostNames
}