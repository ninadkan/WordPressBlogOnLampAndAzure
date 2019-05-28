. "$PSScriptRoot\login.ps1"


# remove container files





Function removeStorageAccount($storageAccountName)
{
    # Lets create the storage account now if it does not exist
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCEGROUP_NAME -Name $storageAccountName -ErrorAction SilentlyContinue
    if (!$storageAccount)
    {
        # create the storage account
        $storageAccount = Remove-AzStorageAccount -ResourceGroupName $RESOURCEGROUP_NAME -Name $storageAccountName 
    }
}


removeStorageAccount -storageAccountName $frontEndStorageAccountName1
removeStorageAccount -storageAccountName $frontEndStorageAccountName2
removeStorageAccount -storageAccountName $diagnosticsStorageAccountName




$availabilityset = get-azavailabilityset  -resourcegroupname $resourcegroup_name -name $availabilitysetname -erroraction silentlycontinue

if ($availabilityset)
{
   #imagine that none of the other constructs are created!!!
   $availabilityset = remove-azavailabilityset -resourcegroupname $resourcegroup_name -name $availabilitysetname
}
