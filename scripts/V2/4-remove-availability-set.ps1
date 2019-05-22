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


clearContainer -storageAccountName $frontEndStorageAccountName1 -containerName "vhds" -FileRemovalFilter "*.vhd"
clearContainer -storageAccountName $frontEndStorageAccountName2 -containerName "vhds" -FileRemovalFilter "*.vhd"



#$availabilitySet = Get-AzAvailabilitySet  -ResourceGroupName $RESOURCEGROUP_NAME -Name $AvailabilitySetName -ErrorAction SilentlyContinue

#if ($availabilitySet)
#{
    # imagine that none of the other constructs are created!!!
    #$availabilitySet = Remove-AzAvailabilitySet -ResourceGroupName $RESOURCEGROUP_NAME -Name $AvailabilitySetName
#}


#$availabilitySet