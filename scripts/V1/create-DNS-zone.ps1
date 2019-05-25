. "$PSScriptRoot\login.ps1"

$StaticIpAddress=""
$FQDN=""

$RunningState=((Get-AzureRmVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $virtualMachineName -Status).Statuses[1]).Code
if ($RunningState -eq "Powerstate/Running")
{
    Write-Host "Getting static UP and FQDN of existing VM";
    $StaticIpAddress = (Get-AzureRmPublicIpAddress -Name "linuxwebfrontend-ip" -ResourceGroupName blog-rg ).IpAddress
    $FQDN = (Get-AzureRmPublicIpAddress -Name "linuxwebfrontend-ip" -ResourceGroupName blog-rg ).DnsSettings.Fqdn
}
else
{
    Write-Host "$virtualMachineName not running. Unable to determine IP address and FQDN";
}

echo "Static Ip Address = $StaticIpAddress"
echo "FQDN = $FQDN"
if ($StaticIpAddress) 
{
    # create DNs Zone if it does not exists. 
    $ExistingDNSZone = Get-AzureRmDnsZone -Name $DNSNAME -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction Continue
    if (!$ExistingDNSZone)
    {
        Write-Host "Creating DNS Zone";
        $NewDNSZone = New-AzureRmDnsZone -Name $DNSNAME -ResourceGroupName $RESOURCEGROUP_NAME
    }
    else
    {
        Write-Host "DNS Zone $SUBSCRIPTION already created";
    }

    Write-Host "creating the DNS Record Set";
    # This setup needs to performed manually as I need to map a Azure resource to the record set which I haven't found an example of as yet!!!
    #New-AzureRmDnsRecordSet -ZoneName $SUBSCRIPTION -ResourceGroupName $RESOURCEGROUP_NAME -Name "@" -RecordType "A"  -Ttl 600 -DnsRecords (New-AzureRmDnsRecordConfig -IPv4Address $StaticIpAddress)
    #New-AzureRmDnsRecordSet -ZoneName $SUBSCRIPTION -ResourceGroupName $RESOURCEGROUP_NAME -Name "@" -RecordType "txt" -Ttl 600 -DnsRecords (New-AzureRmDnsRecordConfig -Value $FQDN )
    #New-AzureRmDnsRecordSet -ZoneName $SUBSCRIPTION -ResourceGroupName $RESOURCEGROUP_NAME -Name "blogs" -RecordType "CNAME" -Ttl 600 -DnsRecords (New-AzureRmDnsRecordConfig -cname $FQDN)
}
else
{
    Write-Host "Static Ip Address = NULL!!!"
}
