. "$PSScriptRoot\login.ps1"


$publicIp = Get-AzPublicIpAddress `
    -Name $publicIpName `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -ErrorAction SilentlyContinue

if (!$publicIp)
{
    Write-Host -ForegroundColor Green "create a new static IP address ... ";
    $publicIp = New-AzPublicIpAddress  -Name $publicIpName `
        -ResourceGroupName $RESOURCEGROUP_NAME -AllocationMethod Static `
        -DomainNameLabel $dnsPrefix -Location $LOCATION -Sku "Standard"
}
else
{
    $addr = $publicIp.IpAddress
    Write-Host -ForegroundColor Cyan "static IP address already exists = '$addr'";
}

#if ($publicIp)
##{
#    Write-Host  -ForegroundColor Green "Using the Public IP address variable";
#    # create DNs Zone if it does not exists. 
#    $ExistingDNSZone = Get-AzDnsZone -Name $DNSNAME `
##                -ResourceGroupName $RESOURCEGROUP_NAME `
#                -ErrorAction Continue
#    if (!$ExistingDNSZone)
#    {
#        Write-Host  -ForegroundColor Green  "Creating DNS Zone";
#        $ExistingDNSZone = New-AzDnsZone -Name $DNSNAME `
#                        -ResourceGroupName $RESOURCEGROUP_NAME
#    }
#    else
#    {
#        Write-Host  -ForegroundColor Cyan  "DNS Zone '$DNSNAME' already created";
#    }

#    if ($ExistingDNSZone)
#    {
#        $existingRecordSet = Get-AzDnsRecordSet -Name $RecordSetName `
#                        -ResourceGroupName $RESOURCEGROUP_NAME `
#                        -RecordType "A" -ZoneName `
#                        $DNSNAME -ErrorAction SilentlyContinue
#        if (-not $existingRecordSet)
#        {
#            Write-Host -ForegroundColor Green "creating a new DNS Record entry... ";
#            $existingRecordSet = New-AzDnsRecordSet -Name $RecordSetName `
#                        -RecordType "A" `
#                        -ResourceGroupName $RESOURCEGROUP_NAME `
#                        -Ttl 3600 `
#                        -TargetResourceId $publicIp.Id `
#                        -ZoneName $DNSNAME
#        }
#        else
#        {
#            Write-Host -ForegroundColor Cyan "Using the existing DNS record";
#        }

#        if (-not $existingRecordSet)
#        {
#            Write-Host -ForegroundColor Red "DNS Record set not found";
#        }
#    }
#    else
#    {
#        Write-Host -ForegroundColor Red "Error! DNS Zone not found";
#    }
#}
#else
#{
#    Write-Host -ForegroundColor Red "Error! Public IP address not found";
#}







