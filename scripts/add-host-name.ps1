#Add Hostname in Azure 
. "$PSScriptRoot\login.ps1"

# assumes that the web app is already created and is configured correctly in the DNS records of the DNS provider

$WebAppInfo = Get-AzureRmWebApp -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_APPNAME


if (!$WebAppInfo.HostNames.Contains($FQDN))
{
    echo "Adding hostname $FQDN"
    $WebAppInfo.HostNames.Add($FQDN)
    Set-AzureRmWebApp -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_APPNAME -HostNames $WebAppInfo.HostNames
}
else
{
    echo "Hostname $FQDN already exists!"
}

