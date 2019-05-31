. "$PSScriptRoot\login.ps1"

$availabilitySet = Get-AzAvailabilitySet  `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -Name $AvailabilitySetName `
    -ErrorAction SilentlyContinue

if (-not $availabilitySet)
{
    # imagine that none of the other constructs are created!!!
    Write-Host  -ForegroundColor Green  "Creating Availability Set '$AvailabilitySetName'"

    $availabilitySet = New-AzAvailabilitySet `
                            -PlatformUpdateDomainCount 2 `
                            -PlatformFaultDomainCount 2 `
                            -ResourceGroupName $RESOURCEGROUP_NAME `
                            -Name $AvailabilitySetName `
                            -Location $LOCATION `
                            -Sku 'Aligned'
                            
}
else
{
    Write-Warning "Availability already exists '$AvailabilitySetName'"
}


Function createStorageAccount($storageAccountName)
{
    # Lets create the storage account now if it does not exist
    $storageAccount = Get-AzStorageAccount `
        -ResourceGroupName $RESOURCEGROUP_NAME `
        -Name $storageAccountName `
        -ErrorAction SilentlyContinue
    if (-not $storageAccount)
    {
        # create the storage account
        Write-Host  -ForegroundColor Green  "Creating storage account '$storageAccountName'"
        $skuName = "Standard_LRS"
        $storageAccount = New-AzStorageAccount `
            -ResourceGroupName $RESOURCEGROUP_NAME `
            -Name $storageAccountName `
            -Location $LOCATION `
            -SkuName $skuName
    }
    else
    {
        Write-Warning "Storage already exists '$storageAccountName'"
    }
}

createStorageAccount -storageAccountName $commonStorageAccountName




