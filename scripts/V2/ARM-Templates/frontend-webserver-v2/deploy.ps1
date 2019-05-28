<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>



param(
 
 [string]
 $subscriptionId="ninadkanthi.co.uk",

 
 [string]
 $resourceGroupName="blog-rg",

 [string]
 $resourceGroupLocation,

 
 [string]
 $deploymentName="frontend-Webserver",

 [string]
 $templateFilePath = "template.json",

 [Parameter(Mandatory=$True)]
 [string]
 $parametersFilePath
)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzResourceProvider -ProviderNamespace $ResourceProviderNamespace;
}

#$storageAccount = Get-AzStorageAccount -ResourceGroupName $RESOURCEGROUP_NAME -Name $frontEndStorageAccountName1
Function clearContainer($storageAccountName, $containerName, $FileRemovalFilter)
{
    $accnt = Get-AzStorageAccount -ResourceGroupName $RESOURCEGROUP_NAME -Name $storageAccountName -ErrorAction Stop
    $storageKey = (Get-AzStorageAccountKey -ResourceGroupName $RESOURCEGROUP_NAME -Name $storageAccountName).Value[0]
    $context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey
    $files = Get-AzStorageBlob -Container $containerName -Context $context -Blob $FileRemovalFilter

    if ($files)
    {
        $blobName = $files[0].Name
        if ($blobName)
        {
            Write-Host "$i : Removing blob $blobName"
            Remove-AzStorageBlob -Container $containerName -Context $context -Blob $blobName
        }
    }
}


. "$PSScriptRoot\..\..\login.ps1"
#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
#Write-Host "Logging in...";
#Login-AzAccount;

# select subscription
#Write-Host "Selecting subscription '$subscriptionId'";
#Select-AzSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.network","microsoft.compute");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}


if ($parametersFilePath.ToLower().Equals("parameters1.json"))
{
    Write-Host "clearing existing containers '$frontEndStorageAccountName1'...";
    clearContainer -storageAccountName $frontEndStorageAccountName1 -containerName "vhds" -FileRemovalFilter "*.vhd"
}
else
{
    Write-Host "clearing existing containers '$frontEndStorageAccountName2'...";
    clearContainer -storageAccountName $frontEndStorageAccountName2 -containerName "vhds" -FileRemovalFilter "*.vhd"
}

# Start the deployment
Write-Host "Starting deployment...";
if(Test-Path $parametersFilePath) {
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath;
} else {
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName -TemplateFile $templateFilePath;
}