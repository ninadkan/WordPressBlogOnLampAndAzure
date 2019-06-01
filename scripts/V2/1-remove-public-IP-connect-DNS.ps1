. "$PSScriptRoot\login.ps1"

$existingRecordSet = Get-AzDnsRecordSet `
    -Name $RecordSetName `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -RecordType "A" `
    -ZoneName $DNSNAME `
    -ErrorAction SilentlyContinue
if ($existingRecordSet)
{
   $existingRecordSet = Remove-AzDnsRecordSet `
    -Name $RecordSetName `
    -RecordType "A" `
    -ZoneName $DNSNAME `
    -ResourceGroupName $RESOURCEGROUP_NAME
}

$publicIp = Get-AzPublicIpAddress `
    -Name $publicIpName `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -ErrorAction SilentlyContinue

if ($publicIp)
{
    Remove-AzPublicIpAddress `
        -Name $publicIpName `
        -ResourceGroupName $RESOURCEGROUP_NAME 
}


