. "$PSScriptRoot\login.ps1"

# Create the app service plan - check if it already exists
$rv = Get-AzureRmAppServicePlan -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_NAME -ErrorAction SilentlyContinue

if ($rv.Name -ne $SERVICEPLAN_NAME)
{
    echo "creating Service Plan = $SERVICEPLAN_NAME"
    $SERVICEPLAN_SKU = "D1"
    az appservice plan create --name $SERVICEPLAN_NAME --resource-group $RESOURCEGROUP_NAME --sku $SERVICEPLAN_SKU
}

# Create a web app - check if it already exists

$rv=Get-AzureRmWebApp -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_APPNAME -ErrorAction SilentlyContinue

if ($rv.Name -ne $SERVICEPLAN_APPNAME)
{
    echo "creating Service Plan Web App = $SERVICEPLAN_APPNAME"
    New-AzureRmWebApp -ResourceGroupName $RESOURCEGROUP_NAME -Name $SERVICEPLAN_APPNAME -AppServicePlan $SERVICEPLAN_NAME
}


