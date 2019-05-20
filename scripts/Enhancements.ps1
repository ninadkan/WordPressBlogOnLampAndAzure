# sign in
Write-Host -ForegroundColor DarkYellow "Logging in...";
Connect-AzAccount
$creds = Connect-AzureAD -TenantId "127ece6f-d748-4235-8a17-7c7cbbe28558"
$displayName = $creds.Account.Id
$onlyName = $displayName.Substring(0,$displayName.IndexOf('@'))
#$user = Get-AzureADUser -All $true |Where-Object {$_.userPrincipalName - "$onlyName"}
$user = Get-AzureADUSer -Filter "startswith(UserPrincipalName, '$onlyName')"

if ($user)
{

    # Set variables
    $resourceGroup = "blog-rg"
    $vmName = "linuxwebfrontend"
    $newAvailSetName = "blog-availability-set"
    # select subscription
    Write-Host -ForegroundColor DarkYellow "Selecting subscription '$SUBSCRIPTION'"
    Select-AzSubscription -Tenant "4ca27440-4053-487c-b024-37a2d898d6da";

    $availSet = Get-AzAvailabilitySet -ResourceGroupName $resourceGroup -Name $newAvailSetName
    if ($availSet)
    {
        Write-Host "Able to get the availability set, lets try adding our VM into it"

        # Get the details of the VM to be moved to the Availability Set
        $originalVM = Get-AzVM `
	           -ResourceGroupName $resourceGroup `
	           -Name $vmName `
               -ErrorAction Continue
               

        # Create new availability set if it does not exist
        $availSet = Get-AzAvailabilitySet `
	           -ResourceGroupName $resourceGroup `
	           -Name $newAvailSetName `
	           -ErrorAction Ignore
        if (-Not $availSet) {
            $availSet = New-AzAvailabilitySet `
	           -Location $originalVM.Location `
	           -Name $newAvailSetName `
	           -ResourceGroupName $resourceGroup `
	           -PlatformFaultDomainCount 2 `
	           -PlatformUpdateDomainCount 2 `
	           -Sku Aligned
        }
    
        # Remove the original VM
        if ($originalVM)
        {
            Remove-AzVM -ResourceGroupName $resourceGroup -Name $vmName    

            # Create the basic configuration for the replacement VM
            $newVM = New-AzVMConfig `
	            -VMName $originalVM.Name `
	            -VMSize $originalVM.HardwareProfile.VmSize `
	            -AvailabilitySetId $availSet.Id
  
            Set-AzVMOSDisk `
	            -VM $newVM -CreateOption Attach `
	            -ManagedDiskId $originalVM.StorageProfile.OsDisk.ManagedDisk.Id `
	            -Name $originalVM.StorageProfile.OsDisk.Name `
	            -Linux

            # Add Data Disks
            foreach ($disk in $originalVM.StorageProfile.DataDisks) { 
            Add-AzVMDataDisk -VM $newVM `
	            -Name $disk.Name `
	            -ManagedDiskId $disk.ManagedDisk.Id `
	            -Caching $disk.Caching `
	            -Lun $disk.Lun `
	            -DiskSizeInGB $disk.DiskSizeGB `
	            -CreateOption Attach
            }
    
            # Add NIC(s) and keep the same NIC as primary
	        foreach ($nic in $originalVM.NetworkProfile.NetworkInterfaces) {	
	        if ($nic.Primary -eq "True")
		        {
    		        Add-AzVMNetworkInterface `
       		        -VM $newVM `
       		        -Id $nic.Id -Primary
       		        }
       	        else
       		        {
       		            Add-AzVMNetworkInterface `
      		            -VM $newVM `
      	 	            -Id $nic.Id 
                        }
  	        }
        # Recreate the VM
        New-AzVM `
	        -ResourceGroupName $resourceGroup `
	        -Location $originalVM.Location `
	        -VM $newVM `
	        -DisableBginfoExtension

        }
    }
    else
    {
        # Create the basic configuration for the replacement VM
        $newVM = New-AzVMConfig `
	        -VMName $vmName `
	        -VMSize "Standard_B2s" `
	        -AvailabilitySetId $availSet.Id

        

        Set-AzVMOSDisk `
	        -VM $newVM -CreateOption Attach `
	        -ManagedDiskId $originalVM.StorageProfile.OsDisk.ManagedDisk.Id `
	        -Name "linuxwebfrontend_OsDisk_1_6bd3e85742a145208a2ff4e08b074ec2" `
	        -Linux
        
    }
}



