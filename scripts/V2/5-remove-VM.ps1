. "$PSScriptRoot\login.ps1"

Function removeLinuxVM($VMName)
{
    $vm = Get-AzVM –Name $VMName `
        –ResourceGroupName $RESOURCEGROUP_NAME `
        -ErrorAction SilentlyContinue
    if ($vm)
    { 
        #Next, we need to get the VM ID. This is required to find the associated boot diagnostics container.
        $azResourceParams = @{
            'ResourceName' = $VMName
            'ResourceType' = 'Microsoft.Compute/virtualMachines'
                'ResourceGroupName' = $RESOURCEGROUP_NAME
        }
        $vmResource = Get-AzResource @azResourceParams
        $vmId = $vmResource.Properties.VmId

        # Remove the boot diagnostics
        removeBootDiagnostics($vm)

        # Remove VM
	    Write-Verbose -Message 'Removing the Azure VM...'
	    $null = $vm | Remove-AzVM -Force
	
        removeOSDisksAndStorage($vm)
    }
    else
    {
        Write-Warning "VM not found for removing '$VMName'"
    }
}



Function removeBootDiagnostics($vm, $vmId)
{
    # Thanks https://4sysops.com/archives/delete-an-azure-vm-with-objects-using-powershell 
    if ($vm.DiagnosticsProfile.bootDiagnostics)
    {
	    Write-Verbose -Message 'Removing boot diagnostics storage container...'
	    $diagSa = [regex]::match($vm.DiagnosticsProfile.bootDiagnostics.storageUri, '^http[s]?://(.+?)\.').groups[1].value
	    if ($vm.Name.Length -gt 9) {
		    $i = 9
	    } else {
		    $i = $vm.Name.Length - 1
	    }

	    $diagContainerName = ('bootdiagnostics-{0}-{1}' -f $vm.Name.ToLower().Substring(0, $i), $vmId)
	    $diagSaRg = (Get-AzStorageAccount | `
            where { $_.StorageAccountName -eq $diagSa }).ResourceGroupName
	    $saParams = @{
		    'ResourceGroupName' = $diagSaRg
		    'Name' = $diagSa
	    }
	    Get-AzStorageAccount @saParams | `
            Get-AzStorageContainer | `
            where { $_.Name-eq $diagContainerName } | `
            Remove-AzStorageContainer -Force
    }
}

Function removeOSDisksAndStorage($vm)
{
    Write-Verbose -Message 'Removing OS disk...'
    $osDiskUri = $vm.StorageProfile.OSDisk.Vhd.Uri
    if ($osDiskUri)
    {
    
        $osDiskContainerName = $osDiskUri.Split('/')[-2]
        ## TODO: Does not account for resouce group 
        $osDiskStorageAcct = Get-AzStorageAccount | where { $_.StorageAccountName -eq $osDiskUri.Split('/')[2].Split('.')[0] }
        $osDiskStorageAcct | Remove-AzStorageBlob -Container $osDiskContainerName -Blob $osDiskUri.Split('/')[-1] -ea Ignore

        #region Remove the status blob
        Write-Verbose -Message 'Removing the OS disk status blob...'
        $osDiskStorageAcct | Get-AzStorageBlob -Container $osDiskContainerName -Blob "$($vm.Name)*.status" | Remove-AzStorageBlob
        #endregion
    }

        ## Remove any other attached disks
    if ($vm.DataDiskNames.Count -gt 0)
    {
	    Write-Verbose -Message 'Removing data disks...'
	    foreach ($uri in $vm.StorageProfile.DataDisks.Vhd.Uri)
	    {
		    $dataDiskStorageAcct = Get-AzStorageAccount -Name $uri.Split('/')[2].Split('.')[0]
		    $dataDiskStorageAcct | Remove-AzStorageBlob -Container $uri.Split('/')[-2] -Blob $uri.Split('/')[-1] -ea Ignore
	    }
    }
}


Function removeManagedDisks()
{
    # Set deleteUnattachedDisks=1 if you want to delete unattached Managed Disks
    # Set deleteUnattachedDisks=0 if you want to see the Id of the unattached Managed Disks
    $deleteUnattachedDisks=1
    $managedDisks = Get-AzDisk
    foreach ($md in $managedDisks) {
        # ManagedBy property stores the Id of the VM to which Managed Disk is attached to
        # If ManagedBy property is $null then it means that the Managed Disk is not attached to a VM
        if($md.ManagedBy -eq $null){
            if($deleteUnattachedDisks -eq 1){
                Write-Host "Deleting unattached Managed Disk with Id: $($md.Id)"
                $md | Remove-AzDisk -Force
                Write-Host "Deleted unattached Managed Disk with Id: $($md.Id) "
            }else{
                $md.Id
            }
        }
     }
}

Function removeUnAttachedUnManagedDisks()
{
    # Set deleteUnattachedVHDs=1 if you want to delete unattached VHDs
    # Set deleteUnattachedVHDs=0 if you want to see the Uri of the unattached VHDs
    $deleteUnattachedVHDs=1
    $storageAccounts = Get-AzStorageAccount
    foreach($storageAccount in $storageAccounts){
        $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName)[0].Value
        $context = New-AzStorageContext -StorageAccountName $storageAccount.StorageAccountName -StorageAccountKey $storageKey
        $containers = Get-AzStorageContainer -Context $context
        foreach($container in $containers){
            $blobs = Get-AzStorageBlob -Container $container.Name -Context $context
            #Fetch all the Page blobs with extension .vhd as only Page blobs can be attached as disk to Azure VMs
            $blobs | Where-Object {$_.BlobType -eq 'PageBlob' -and $_.Name.EndsWith('.vhd')} | ForEach-Object { 
                #If a Page blob is not attached as disk then LeaseStatus will be unlocked
                if($_.ICloudBlob.Properties.LeaseStatus -eq 'Unlocked'){
                        if($deleteUnattachedVHDs -eq 1){
                            Write-Host "Deleting unattached VHD with Uri: $($_.ICloudBlob.Uri.AbsoluteUri)"
                            $_ | Remove-AzStorageBlob -Force
                            Write-Host "Deleted unattached VHD with Uri: $($_.ICloudBlob.Uri.AbsoluteUri)"
                        }
                        else{
                            $_.ICloudBlob.Uri.AbsoluteUri
                        }
                }
            }
        }
}
}



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


removeLinuxVM -VMName $FrontEndVMName1
removeLinuxVM -VMName $FrontEndVMName2
removeLinuxVM -VMName $BackEndVMName

# Remove any detached managed and unmanaged disks
removeUnAttachedUnManagedDisks
removeManagedDisks

#RemoveSecondaryNIcs -SecondaryNICName $SecondaryNwInterfaceFrontEnd1Name
#RemoveSecondaryNIcs -SecondaryNICName $SecondaryNwInterfaceFrontEnd2Name
#RemoveSecondaryNIcs -SecondaryNICName $SecondaryNwInterfaceBackEnd

