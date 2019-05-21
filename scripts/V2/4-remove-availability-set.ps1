. "$PSScriptRoot\login.ps1"

$availabilitySet = Get-AzAvailabilitySet  -ResourceGroupName $RESOURCEGROUP_NAME -Name $AvailabilitySetName -ErrorAction SilentlyContinue

if ($availabilitySet)
{
    # imagine that none of the other constructs are created!!!
    $availabilitySet = Remove-AzAvailabilitySet -ResourceGroupName $RESOURCEGROUP_NAME -Name $AvailabilitySetName
}


$availabilitySet