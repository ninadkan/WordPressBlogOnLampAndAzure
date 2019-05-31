. "$PSScriptRoot\login.ps1"

Function createNSG($NsgName,  $addRules)
{
    $NSG = Get-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME `
                                 -Name $NsgName -ErrorAction SilentlyContinue
    if (-not $NSG)
    {
        Write-Host -ForegroundColor Green "creating a new NSG '$NsgName' ... "
        if ($addRules)
        {

            Write-Host -ForegroundColor Green "creating new rule for '$NsgName' ... "
            $rules = @()

            $httpRule = New-AzNetworkSecurityRuleConfig -Name $httpSecurityRuleName `
                -Description "Allow HTTP" -Access Allow `
                -Protocol Tcp -Direction Inbound -Priority 1010 `
                -SourceAddressPrefix Internet -SourcePortRange * `
                -DestinationAddressPrefix * -DestinationPortRange 80

            $httpsRule = New-AzNetworkSecurityRuleConfig -Name $httpsSecurityRuleName `
                -Description "Allow HTTPS" -Access Allow `
                -Protocol Tcp -Direction Inbound -Priority 1020 `
                -SourceAddressPrefix Internet -SourcePortRange * `
                -DestinationAddressPrefix * -DestinationPortRange 443

            $rules += $httpRule 
            $rules += $httpsRule 
            
            $NSG = New-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME `
                -Location $LOCATION `
                -Name $NsgName `
                -SecurityRules $rules
        }
        else
        {
            $NSG = New-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME `
                    -Location $LOCATION `
                    -Name $NsgName
        }
    }
    else
    {
        Write-Warning ("Already exists - '$NsgName'")
    }
    return $NSG
}

Function createSubNet($SubnetName, $virtualNetwork, $AddresPrefix)
{
    $Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName `
            -VirtualNetwork $virtualNetwork -ErrorAction SilentlyContinue
    if (-not $Subnet)
    {
        Write-Host -ForegroundColor Green "creating a new subnet '$SubnetName'... "
        $Subnet = Add-AzVirtualNetworkSubnetConfig -Name $SubnetName `
                -AddressPrefix $AddresPrefix -VirtualNetwork $virtualNetwork
    }
    else
    {
        Write-Warning ("Already exists - '$SubnetName'")
    }
    return $Subnet
}



$VnetAddressPrefix = "10.0.0.0/16"
$frontendSubnetAddresPrefix = "10.0.1.0/24"
$backEndSubnetAdressPrefix = "10.0.2.0/24"


$virtualNetwork  = Get-AzVirtualNetwork -Name $VirtualNetworkName `
        -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction SilentlyContinue 
if (-not $virtualNetwork)
{
    Write-Host -ForegroundColor Green "create a new VNET ... ";
    $virtualNetwork = New-AzVirtualNetwork `
                        -ResourceGroupName $RESOURCEGROUP_NAME `
                        -Location $LOCATION -Name $VirtualNetworkName `
                        -AddressPrefix $VnetAddressPrefix
}
else
{
     Write-Warning ("Already exists - '$VirtualNetworkName'")
}

if ($virtualNetwork)
{

    # create the subnets
    $frontEndSubnet = createSubNet -SubnetName $FrontEndSubnetName `
                -virtualNetwork $virtualNetwork `
                -AddresPrefix $frontendSubnetAddresPrefix 
    $backendSubnet = createSubNet -SubnetName $BackendSubnetName `
                -virtualNetwork $virtualNetwork `
                -AddresPrefix $backEndSubnetAdressPrefix 

    # check if subnets exists
    if ((-not $frontEndSubnet) -or (-not $backendSubnet))
    {
        if (-not $frontEndSubnet)
        {
            Write-Host -ForegroundColor Red "Error! SUB-VNET '$FrontEndSubnetName' not found"
        }

        if (-not $backendSubnet)
        {
            Write-Host -ForegroundColor Red "Error! SUB-VNET '$BackendSubnetName' not found"
        }
    }
    else
    {
        # both subnets exist now; save status ; 
        $dummy = Set-AzVirtualNetwork -VirtualNetwork $virtualNetwork 

        # lets update with NSGS
        $frontendNSG = createNSG -NsgName $FrontEndNSGName -addRules $true
        $backendNSG = createNSG -NsgName  $BackEndNSGName -addRules $false


        if ($frontendNSG)
        {
            $dummy = Set-AzVirtualNetworkSubnetConfig -Name $FrontEndSubnetName `
                -VirtualNetwork $virtualNetwork -NetworkSecurityGroup $frontEndNSG `
                -AddressPrefix $frontendSubnetAddresPrefix 
        }
        else
        {
            Write-Host -ForegroundColor Red "Error! NSG '$FrontEndSubnetName' not found"
        }
        

        if ($backendNSG)
        {
            $dummy = Set-AzVirtualNetworkSubnetConfig -Name $BackendSubnetName `
                    -VirtualNetwork $virtualNetwork `
                    -NetworkSecurityGroup $backendNSG `
                    -AddressPrefix $backEndSubnetAdressPrefix 
        }
        else
        {
            Write-Host -ForegroundColor Red "Error! NSG '$BackendSubnetName' not found"
        }
        $dummy =  Set-AzVirtualNetwork -VirtualNetwork $virtualNetwork
    }
}
else
{
    Write-Host -ForegroundColor Red "Error! VNET '$VirtualNetworkName' not found"
}

