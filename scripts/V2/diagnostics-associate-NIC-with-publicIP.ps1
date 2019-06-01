. "$PSScriptRoot\login.ps1"




Function AttachNicAndPublicIP($NicName, $PublicIPAddressName)
{
    $vnet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $RESOURCEGROUP_NAME
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $FrontEndSubnetName -VirtualNetwork $vnet
    $nic = Get-AzNetworkInterface -Name $NicName -ResourceGroupName $RESOURCEGROUP_NAME
    $pip = Get-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $RESOURCEGROUP_NAME

    $ipConfig = Get-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic

    $nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -PublicIpAddress $pip -Subnet $subnet -Primary
    $nic.EnableIPForwarding = 1
    $nic | Set-AzNetworkInterface
}

Function DetachNICAndPublicIP($NicName, $PublicIPAddressName)
{
    $vnet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $RESOURCEGROUP_NAME
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $FrontEndSubnetName -VirtualNetwork $vnet
    $nic = Get-AzNetworkInterface -Name $NicName -ResourceGroupName $RESOURCEGROUP_NAME
    $pip = Get-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $RESOURCEGROUP_NAME


    $ipConfig = Get-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic
    #$nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -Subnet $subnet  -Primary
    Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic -Subnet $subnet -Primary
    $nic | Set-AzNetworkInterface
}

Function clearContainer($storageAccountName, $containerName, $FileRemovalFilter)
{
    $accnt = Get-AzStorageAccount `
        -ResourceGroupName $RESOURCEGROUP_NAME `
        -Name $storageAccountName `
        -ErrorAction Stop
    $storageKey = (Get-AzStorageAccountKey `
        -ResourceGroupName $RESOURCEGROUP_NAME `
        -Name $storageAccountName).Value[0]
    $context = New-AzStorageContext `
        -StorageAccountName $storageAccountName `
        -StorageAccountKey $storageKey
    $files = Get-AzStorageBlob `
        -Container $containerName `
        -Context $context `
        -Blob $FileRemovalFilter `
        -ErrorAction SilentlyContinue
        

    if ($files)
    {
        $blobName = $files[0].Name
        if ($blobName)
        {
            Write-Host "$i : Removing blob $blobName"
            Remove-AzStorageBlob -Container $containerName -Context $context -Blob $blobName
        }
    }
}



#AttachNicAndPublicIP -NicName $NwInterfaceFront1 -PublicIPAddressName $publicIpName
#DetachNICAndPublicIP -NicName $NwInterfaceFront1 -PublicIPAddressName $publicIpName

#AttachNicAndPublicIP -NicName $NwInterfaceFront2 -PublicIPAddressName $publicIpName
#DetachNICAndPublicIP -NicName $NwInterfaceFront2 -PublicIPAddressName $publicIpName

#Function AttachNicAndPublicIP($NicName, $PublicIPAddressName)
#{
#    $vnet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $RESOURCEGROUP_NAME
#    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $FrontEndSubnetName -VirtualNetwork $vnet
#    $nic = Get-AzNetworkInterface -Name $NicName -ResourceGroupName $RESOURCEGROUP_NAME
#    $pip = Get-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $RESOURCEGROUP_NAME

#    $ipConfig = Get-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic

#    $nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -PublicIpAddress $pip -Subnet $subnet -Primary
#    $nic.EnableIPForwarding = 1
#    $nic | Set-AzNetworkInterface
#}




#createVM -templateFilePath "template_backend.json" -deploymentName "backend-deployment" -parametersFilePath "parameters_backend.json"
#createVM -templateFilePath "template_frontend.json" -deploymentName "frontend-deployment-1" -parametersFilePath "parameters_frontend_1.json"
#createVM -templateFilePath "template_frontend.json" -deploymentName "frontend-deployment-2" -parametersFilePath "parameters_frontend_2.json"


#Function GetCreateSecondaryNIC($nicName,$Subnet, $NSG )
#{

#    $nic = Get-AzNetworkInterface `
#            -Name $nicName `
#            -ResourceGroupName $RESOURCEGROUP_NAME `
#            -ErrorAction SilentlyContinue

#    if (-not $nic)
#    {
#        Write-Host -ForegroundColor Green `
#            "create a new network interface  '$nicName'... ";
#        $nic = New-AzNetworkInterface `
#            -Name $nicName `
#            -ResourceGroupName $RESOURCEGROUP_NAME `
#            -Location $LOCATION `
#           -SubnetId $Subnet.Id `
#            -NetworkSecurityGroupId $NSG.Id `
#            -EnableIPForwarding 
#    }

#    return $nic
#}

#$virtualNetwork  = Get-AzVirtualNetwork `
#    -Name $VirtualNetworkName `
#    -ResourceGroupName $RESOURCEGROUP_NAME `
#    -ErrorAction Stop

#$frontEndSubnet = Get-AzVirtualNetworkSubnetConfig `
#    -Name $FrontEndSubnetName `
#    -VirtualNetwork $virtualNetwork `
#    -ErrorAction Stop
#$backendSubnet = Get-AzVirtualNetworkSubnetConfig `
#    -Name $BackendSubnetName `
#    -VirtualNetwork $virtualNetwork `
#    -ErrorAction Stop

#$frontendNSG = Get-AzNetworkSecurityGroup `
#    -ResourceGroupName $RESOURCEGROUP_NAME `
#    -Name $FrontEndNSGName `
#    -ErrorAction Stop
#$backendNSG = Get-AzNetworkSecurityGroup `
#    -ResourceGroupName $RESOURCEGROUP_NAME `
#    -Name $BackEndNSGName `
#    -ErrorAction Stop


#$SecondaryNICFrontEnd1 = GetCreateSecondaryNIC `
#    -nicName $SecondaryNwInterfaceFrontEnd1Name `
#   -Subnet $frontEndSubnet `
#    -NSG $frontendNSG

#$SecondaryNICFrontEnd2 = GetCreateSecondaryNIC `
#    -nicName $SecondaryNwInterfaceFrontEnd2Name `
#    -Subnet $frontEndSubnet `
#    -NSG $frontendNSG

#$SecondaryNICBackEnd1 = GetCreateSecondaryNIC `
#    -nicName $SecondaryNwInterfaceBackEnd `
#    -Subnet $backendSubnet `
#    -NSG $backendNSG

#AttachNicAndPublicIP -NicName $NwInterfaceBack1 `
#    -PublicIPAddressName $temporaryIPAddressName


# Don't remove the DNS ZONE, BAD
#$ExistingDNSZone = Get-AzDnsZone -Name $DNSNAME -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction Continue
#if ($ExistingDNSZone)
#{
#    $ExistingDNSZone = Remove-AzDnsZone -Name $DNSNAME -ResourceGroupName $RESOURCEGROUP_NAME
#}


#Function DetachNICAndPublicIP($NicName, $PublicIPAddressName)
#{
#    $vnet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $RESOURCEGROUP_NAME
#    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $FrontEndSubnetName -VirtualNetwork $vnet
#    $nic = Get-AzNetworkInterface -Name $NicName -ResourceGroupName $RESOURCEGROUP_NAME
#    $pip = Get-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $RESOURCEGROUP_NAME


#    $ipConfig = Get-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic
    #$nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -Subnet $subnet  -Primary
#    Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic -Subnet $subnet -Primary
#    $nic | Set-AzNetworkInterface
#}

#Function RemoveSecondaryNIcs($SecondaryNICName)
#{
#
#    $nic = Get-AzNetworkInterface `
#            -Name $SecondaryNICName `
#            -ResourceGroupName $RESOURCEGROUP_NAME `
#            -ErrorAction SilentlyContinue

#    if ($nic)
#    {
#        Write-Host -ForegroundColor Green `
#            "Removing the secondary NIC '$SecondaryNICName'... ";
#        Remove-AzNetworkInterface `
#            -Name $SecondaryNICName `
#            -ResourceGroupName $RESOURCEGROUP_NAME
 
#    }
#}

#RemoveSecondaryNIcs -SecondaryNICName $SecondaryNwInterfaceFrontEnd1Name
#RemoveSecondaryNIcs -SecondaryNICName $SecondaryNwInterfaceFrontEnd2Name
#RemoveSecondaryNIcs -SecondaryNICName $SecondaryNwInterfaceBackEnd

        # Will this work? I am creating a new NIC with previous name
        #$nic = New-AzNetworkInterface `
        #    -Name $nicName `
        #    -ResourceGroupName $RESOURCEGROUP_NAME `
        #    -Location $LOCATION `
        #    -SubnetId $Subnet.Id `
        #    -NetworkSecurityGroupId $NSG.Id `
        #    -PublicIpAddressId $temporaryIP.Id

        #Set-AzNetworkInterfaceIpConfig `
        #    -Name $nic.IpConfigurations[0].Name `
        #    -NetworkInterface $nic `


        #$nwInterface = Get-AzNetworkInterface `
        #    -Name $originalNetworkInterfaceName `
        #    -ResourceGroupName $RESOURCEGROUP_NAME
        #$nwInterface.Primary = $true
        #Set-AzNetworkInterface -NetworkInterface $nwInterface

        #Add-AzVMNetworkInterface `
        #    -VM $VM `
        #    -NetworkInterface $nic 

        #$VM.NetworkProfile.NetworkInterfaces[0].Primary = $true; 
                
                
        #Update-AzVM `
        #    -ResourceGroupName $RESOURCEGROUP_NAME `
        #    -VM $VM

#Stop-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndVMName1
#Stop-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndVMName2
#Stop-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $BackEndVMName

#Start-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndVMName1
#Start-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndVMName2
#Start-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $BackEndVMName

# this is used for debugging where the public IP can be plugged directly with the Network Interface cards

#function detachPublicIPfromNIC($nicName)
#{
#    $nic = Get-AzNetworkInterface `
#            -Name $nicName `
#            -ResourceGroupName $RESOURCEGROUP_NAME
   #$nic.IpConfigurations[0].PublicIpAddress=$null
    #Set-AzNetworkInterface -NetworkInterface $nic 
#    $ipConfig = Get-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic
    #$nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -Subnet $subnet  -Primary
#    Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic -Subnet $subnet -Primary
#    $nic | Set-AzNetworkInterface
#}


    #$nsg = Get-AzureRmNetworkSecurityGroup
    #$nsg | Add-AzureRmNetworkSecurityRuleConfig 
    #$nsg | Set-AzureRmNetworkSecurityGroup


    # detach the public IP from the NICs
#detachPublicIPfromNIC -nicName $NwInterfaceBack1
#detachPublicIPfromNIC -nicName $NwInterfaceFront1
#detachPublicIPfromNIC -nicName $NwInterfaceFront2

# Backward compatibility
#removeTemporaryIPAddresses -TempIPAddressName  $temporaryIPAddressName








