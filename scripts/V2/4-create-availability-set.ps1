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


Function createStorageAccount($storageAccountName)
{
    # Lets create the storage account now if it does not exist
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCEGROUP_NAME -Name $storageAccountName -ErrorAction SilentlyContinue
    if (!$storageAccount)
    {
        # create the storage account
        Write-Host "Creating storage account '$storageAccountName'"
        $skuName = "Standard_LRS"
        $storageAccount = New-AzStorageAccount -ResourceGroupName $RESOURCEGROUP_NAME -Name $storageAccountName -Location $LOCATION -SkuName $skuName
    }
}

createStorageAccount -storageAccountName $frontEndStorageAccountName1
createStorageAccount -storageAccountName $frontEndStorageAccountName2
createStorageAccount -storageAccountName $diagnosticsStorageAccountName




