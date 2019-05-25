. "$PSScriptRoot\login.ps1"

$SubscriptionNameList =$(az account list --query [].name -o json)

if ($SubscriptionNameList.Count -eq 0){
    echo "Subscription list contained null values! "
}
else
{

    # create the resource group - check if it already exists
    $rv = az group exists -n $RESOURCEGROUP_NAME
    $rv = TrimVariable $rv

    if ($rv -eq "true")
    {
        echo "Resource group exists : $RESOURCEGROUP_NAME"
    }
    else
    {
        echo "creating resource group = $RESOURCEGROUP_NAME"
        az group create --name $RESOURCEGROUP_NAME --location $LOCATION
        az group wait --created --resource-group $RESOURCEGROUP_NAME
    }

    # Create the app service plan - check if it already exists
    $rv=az appservice plan show -n $SERVICEPLAN_NAME -g $RESOURCEGROUP_NAME --subscription $SUBSCRIPTION --query name -o json
    $rv = TrimVariable $rv

    if ($rv -ne $SERVICEPLAN_NAME)
    {
        echo "creating Service Plan = $SERVICEPLAN_NAME"
        $SERVICEPLAN_SKU = "D1"

        # New-AzureRmAppServicePlan -Name $SERVICEPLAN_NAME -Location $LOCATION -ResourceGroupName$RESOURCEGROUP_NAME -Tier Free
        az appservice plan create --name $SERVICEPLAN_NAME --resource-group $RESOURCEGROUP_NAME --sku $SERVICEPLAN_SKU
    }

    # Create a web app - check if it already exists

    $rv=az webapp show -n $SERVICEPLAN_APPNAME -g $RESOURCEGROUP_NAME --subscription $SUBSCRIPTION --query name -o json
    $rv = TrimVariable $rv

    if ($rv -ne $SERVICEPLAN_APPNAME)
    {
        echo "creating Service Plan Web App = $SERVICEPLAN_APPNAME"
        az webapp create --name $SERVICEPLAN_APPNAME --resource-group $RESOURCEGROUP_NAME --plan $SERVICEPLAN_NAME
    }
}


