. "$PSScriptRoot\login.ps1"

Function removeNSG($NsgName)
{
    $NSG = Get-AzNetworkSecurityGroup `
            -ResourceGroupName $RESOURCEGROUP_NAME `
            -Name $NsgName -ErrorAction SilentlyContinue
    if ($NSG)
    {
        #remove the NSG from the attached Subnet first
         $NSG = Remove-AzNetworkSecurityGroup `
            -ResourceGroupName $RESOURCEGROUP_NAME -Name $NsgName
    }
    else
    {
        Write-Warning "Not found '$NsgName' for Removal"
    }
}

Function removeSubNet($SubnetName, $virtualNetwork)
{
    $Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName `
        -VirtualNetwork $virtualNetwork -ErrorAction SilentlyContinue
    if ($Subnet)
    {
        $Subnet = Remove-AzVirtualNetworkSubnetConfig -Name $SubnetName `
        -VirtualNetwork $virtualNetwork
        $virtualNetwork | Set-AzVirtualNetwork
    }
    else
    {
        Write-Warning "Not found '$SubnetName' for Removal"
    }
    return $Subnet
}


$virtualNetwork  = Get-AzVirtualNetwork -Name $VirtualNetworkName `
        -ResourceGroupName $RESOURCEGROUP_NAME `
        -ErrorAction SilentlyContinue
if ($virtualNetwork)
{

    removeSubNet -SubnetName $FrontEndSubnetName `
        -virtualNetwork $virtualNetwork
    removeSubNet -SubnetName $BackendSubnetName `
        -virtualNetwork $virtualNetwork
  
    Remove-AzVirtualNetwork -ResourceGroupName $RESOURCEGROUP_NAME `
        -Name $VirtualNetworkName
}
else
{
    Write-Warning "Not found '$VirtualNetworkName' for Removal"
}

removeNsg -NsgName $FrontEndNSGName
removeNsg -NsgName $BackEndNSGName



