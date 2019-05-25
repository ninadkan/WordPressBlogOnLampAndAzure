. "$PSScriptRoot\parameters.ps1"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$SUBSCRIPTION'";
Select-AzureRmSubscription -Subscription $SUBSCRIPTION;

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $RESOURCEGROUP_NAME -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$RESOURCEGROUP_NAME' does not exist. To create a new resource group, please enter a location.";
    if(!$LOCATION) {
        $LOCATION = Read-Host "LOCATION";
    }
    Write-Host "Creating resource group '$RESOURCEGROUP_NAME' in location '$LOCATION'";
    New-AzureRmResourceGroup -Name $RESOURCEGROUP_NAME -Location $LOCATION
}
else{
    Write-Host "Using existing resource group '$RESOURCEGROUP_NAME'";
}

