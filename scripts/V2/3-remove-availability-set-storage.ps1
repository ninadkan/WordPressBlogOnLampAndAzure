. "$PSScriptRoot\login.ps1"


# remove container files


#$storageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCEGROUP_NAME -Name $frontEndStorageAccountName1
Function clearContainer($storageAccountName, $containerName, $FileRemovalFilter)
{
    $accnt = Get-AzStorageAccount -ResourceGroupName $RESOURCEGROUP_NAME -Name $storageAccountName -ErrorAction Stop
    $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $RESOURCEGROUP_NAME -Name $storageAccountName).Value[0]
    $context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey
    $files = Get-AzStorageBlob -Container $containerName -Context $context -Blob $FileRemovalFilter

    if ($files)
    {
        for ($i=0; $i -le $files.Length; $i++)
        {
            $blobName = $files[$i].Name
            if ($blobName)
            {
                Remove-AzStorageBlob -Container $containerName -Context $context -Blob $blobName
            }
        }
    }
}


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


clearContainer -storageAccountName $frontEndStorageAccountName1 -containerName "vhds" -FileRemovalFilter "*.vhd"
clearContainer -storageAccountName $frontEndStorageAccountName2 -containerName "vhds" -FileRemovalFilter "*.vhd"

removeStorageAccount -storageAccountName $frontEndStorageAccountName1
removeStorageAccount -storageAccountName $frontEndStorageAccountName2
removeStorageAccount -storageAccountName $diagnosticsStorageAccountName




$availabilityset = get-azavailabilityset  -resourcegroupname $resourcegroup_name -name $availabilitysetname -erroraction silentlycontinue

if ($availabilityset)
{
   #imagine that none of the other constructs are created!!!
   $availabilityset = remove-azavailabilityset -resourcegroupname $resourcegroup_name -name $availabilitysetname
}
