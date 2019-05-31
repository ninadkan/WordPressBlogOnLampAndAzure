. "$PSScriptRoot\login.ps1"


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



Function createVM($nwInterfaceName, $VMName)
{

    $vm = Get-AzVM -Name $VMName `
        -ResourceGroupName $RESOURCEGROUP_NAME `
        -ErrorAction SilentlyContinue
    if (-not $vm)
    { 
 
        $securePassword = ConvertTo-SecureString ' ' -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ($WebUserName, $securePassword)

        $nwInterface = Get-AzNetworkInterface `
            -Name $nwInterfaceName `
            -ResourceGroupName $RESOURCEGROUP_NAME


        $availabilitySet = Get-AzAvailabilitySet  `
            -ResourceGroupName $RESOURCEGROUP_NAME `
            -Name $AvailabilitySetName `


        $vmConfig = New-AzVMConfig -VMName $VMName `
            -VMSize Standard_B1s `
            -AvailabilitySetId $availabilitySet.Id  `
         | Set-AzVMOperatingSystem -Linux `
           -ComputerName $VMName `
           -Credential $cred `
           -DisablePasswordAuthentication `
         | Set-AzVMSourceImage -PublisherName Canonical `
           -Offer UbuntuServer `
           -Skus 16.04-LTS `
           -Version latest `
         | Add-AzVMNetworkInterface -Id $nwInterface.Id `
            -Primary 
         #| Add-AzVMNetworkInterface -Id $SecondaryNIC.Id


        $sshPublicKey = cat ~/.ssh/id_rsa.pub 

        #Write-Host $sshPublicKey

        $keypath=  "/home/" + $WebUserName + "/.ssh/authorized_keys"

        #Write-Host $keypath

        $dummy = Add-AzVMSshPublicKey -VM $vmconfig -KeyData $sshPublicKey -Path $keypath
        $dummy = New-AzVM -VM $vmConfig -ResourceGroupName $RESOURCEGROUP_NAME -Location $LOCATION
    }
    else
    {
        Write-Warning "VM alerady existing - '$VMName'"
    }
}



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


# creating the backend first here
createVM -nwInterfaceName $NwInterfaceBack1 `
    -VMName $BackEndVMName `
    -SecondaryNIC $SecondaryNICBackEnd1

createVM -nwInterfaceName $NwInterfaceFront1 `
    -VMName $FrontEndVMName1 `
    -SecondaryNIC $SecondaryNICFrontEnd1
createVM -nwInterfaceName $NwInterfaceFront2 `
    -VMName $FrontEndVMName2 `
    -SecondaryNIC $SecondaryNICFrontEnd2


#AttachNicAndPublicIP -NicName $NwInterfaceBack1 `
#    -PublicIPAddressName $temporaryIPAddressName

