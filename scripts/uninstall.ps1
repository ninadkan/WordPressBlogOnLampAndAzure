. "$PSScriptRoot\login.ps1"

# Remove service plan web app
$rv=Get-AzureRmWebApp -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_APPNAME -ErrorAction SilentlyContinue

if ($rv.Name -eq $SERVICEPLAN_APPNAME)
{
    echo "Removing Service Plan Web App = $SERVICEPLAN_APPNAME"
    Remove-AzureRmWebApp -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_APPNAME
}

# Remove service plan 
$rv = Get-AzureRmAppServicePlan -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_NAME -ErrorAction SilentlyContinue
if ($rv.Name -eq $SERVICEPLAN_NAME)
{
    
    echo "Removing Service Plan = $SERVICEPLAN_NAME"
    Remove-AzureRmAppServicePlan -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_NAME
}

# Removing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $RESOURCEGROUP_NAME -ErrorAction SilentlyContinue
if($resourceGroup.ResourceGroupName -eq $RESOURCEGROUP_NAME )
{
    Write-Host "Removing resource group '$RESOURCEGROUP_NAME' in location '$LOCATION'";
    Remove-AzureRmResourceGroup -Name $RESOURCEGROUP_NAME
}






#Logout
#$USERNAME=""
#Logout-AzureRmAccount -Username $USERNAME