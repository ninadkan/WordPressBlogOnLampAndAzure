. "$PSScriptRoot\login.ps1"


# remove container files

Function removeStorageAccount($storageAccountName)
{
    # Lets create the storage account now if it does not exist
    $storageAccount = Get-AzStorageAccount `
        -ResourceGroupName $RESOURCEGROUP_NAME `
        -Name $storageAccountName `
        -ErrorAction SilentlyContinue
    if ($storageAccount)
    {
        Write-Host -ForegroundColor Green "Removing Storage  '$storageAccountName'"
        $storageAccount = Remove-AzStorageAccount `
            -ResourceGroupName $RESOURCEGROUP_NAME `
            -Name $storageAccountName 
    }
    else
    {
        Write-Warning "Not found '$storageAccountName' for Removal"
    }

}


removeStorageAccount -storageAccountName $commonStorageAccountName


$availabilityset = get-azavailabilityset  `
    -resourcegroupname $resourcegroup_name `
    -name $availabilitysetname `
    -erroraction silentlycontinue

if ($availabilityset)
{
   #imagine that none of the other constructs are created!!!
   Write-Host -ForegroundColor Green "Removing availabilityset  '$availabilitysetname'"
   $availabilityset = remove-azavailabilityset `
        -resourcegroupname $resourcegroup_name `
        -name $availabilitysetname
}
else
{
    Write-Warning "Not found '$availabilitysetname' for Removal"
}
