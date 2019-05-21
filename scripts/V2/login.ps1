. "$PSScriptRoot\parameters.ps1"

# sign in
Write-Host -ForegroundColor White "Logging in...";
Login-AzAccount;

# select subscription
Write-Host -ForegroundColor White "Selecting subscription '$SUBSCRIPTION'";
Select-AzSubscription -Subscription $SUBSCRIPTION;

#Create or check for existing resource group
$resourceGroup = Get-AzResourceGroup -Name $RESOURCEGROUP_NAME -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host -ForegroundColor Yellow "Resource group '$RESOURCEGROUP_NAME' does not exist. To create a new resource group, please enter a location.";
    if(!$LOCATION) {
        $LOCATION = Read-Host "LOCATION";
    }
    Write-Host -ForegroundColor Cyan "Creating resource group '$RESOURCEGROUP_NAME' in location '$LOCATION'";
    New-AzResourceGroup -Name $RESOURCEGROUP_NAME -Location $LOCATION
}
else
{
    Write-Host -ForegroundColor Green "Using existing resource group '$RESOURCEGROUP_NAME'";
}

