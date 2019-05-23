. "$PSScriptRoot\parameters.ps1"




function Login
{
    $needLogin = $true
    Try 
    {
        $content = Get-AzContext
        if ($content) 
        {
            $needLogin = ([string]::IsNullOrEmpty($content.Account))
        } 
    } 
    Catch 
    {
        if ($_ -like "*Login-AzAccount to login*") 
        {
            $needLogin = $true
        } 
        else 
        {
            throw
        }
    }

    if ($needLogin)
    {
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
    }
}

# sign in
Login

