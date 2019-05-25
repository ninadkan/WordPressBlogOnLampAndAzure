. "$PSScriptRoot\login.ps1"

# assumes that the web app is already created
$WebAppInfo = Get-AzureRmWebApp -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_APPNAME

$AllAddresses = $WebAppInfo.OutboundIpAddresses
# extract the first IP address from the collection provided 
$FirstIpAddress =  $AllAddresses.split(",")[0]
Echo "IpAddress ==> $FirstIpAddress"


$HostName = $WebAppInfo.DefaultHostName
echo "HostName ==> $HostName"

