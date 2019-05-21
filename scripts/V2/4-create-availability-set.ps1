. "$PSScriptRoot\login.ps1"

$availabilitySet = Get-AzAvailabilitySet  -ResourceGroupName $RESOURCEGROUP_NAME -Name $AvailabilitySetName -ErrorAction SilentlyContinue

if (-not $availabilitySet)
{
    # imagine that none of the other constructs are created!!!
    $availabilitySet = New-AzAvailabilitySet -PlatformUpdateDomainCount 2 `
                            -PlatformFaultDomainCount 2 `
                            -ResourceGroupName $RESOURCEGROUP_NAME `
                            -Name $AvailabilitySetName `
                            -Location $LOCATION
}



# Lets start creating the VMs

# Define a credential object
$securePassword = ConvertTo-SecureString 'Dietpepsi-99!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("ninadk", $securePassword)


# B1ls £3.27
# B1ms £13.09
# B1s £6.65
# B2s £26.17

# Create a virtual machine configuration
for ($i=1; $i -le 3; $i++)
{

    $VmName = "$FrontEndVMName-$i"
    $Computername = "$VmName-ubuntu"
    $nwiface = $NwInterfaceFront1
    if ($i -eq 2)
    {
        $nwiface = $NwInterfaceFront2
    }
    $nic = Get-AzNetworkInterface -Name $nwiface -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction Stop
    $VMDataDisk = "ninadkazvmdatadisk$i"
    $OSDataDisk = "ninadkazvmosdisk$i"

    $sshPublicKey = cat '..\..\NoAdd\Linux\Keys\public key'


    $vmConfig = New-AzVMConfig `
      -VMName $VmName `
      -VMSize "Standard_B1ms" `
      -AvailabilitySetId $availabilitySet.Id | `
    Set-AzVMOperatingSystem `
      -Linux `
      -ComputerName $Computername `
      -Credential $cred `
      -DisablePasswordAuthentication | `
    #Set-AzVMDataDisk -Name $VMDataDisk -StorageAccountType "Standard_LRS" `
    #    -DiskSizeInGB "200" | `
    #Set-AzVMOSDisk -Name $OSDataDisk -StorageAccountType "Standard_LRS" `
    #    -DiskSizeInGB "100" |`
    Set-AzVMSourceImage `
      -PublisherName "Canonical" `
      -Offer "UbuntuServer" `
      -Skus "16.04-LTS" `
      -Version "latest" | `
    Add-AzVMNetworkInterface `
       -Id $nic.Id 

    Add-AzVMSshPublicKey `
      -VM $vmconfig `
      -KeyData $sshPublicKey.ToString() `
      -Path "/home/ninadk/.ssh/authorized_keys"

    New-AzVM `
      -ResourceGroupName $RESOURCEGROUP_NAME `
      -Location $LOCATION -VM $vmConfig 
      }


#for ($i=1; $i -le 3; $i++)
#{
#    $VMMachineName = "$FrontEndVMName$i"
#    New-AzVm `
#        -ResourceGroupName $RESOURCEGROUP_NAME `
#        -Name $VMMachineName `
#        -Location $LOCATION `
#        -VirtualNetworkName $VirtualNetworkName `
#        -SubnetName $FrontEndSubnetName `
#        -SecurityGroupName $FrontEndNSGName `
#        -OpenPorts 80, 443,22 `
#        -AvailabilitySetName $AvailabilitySetName `
#        -Credential $cred `
#        -AsJob
#
#}