. "$PSScriptRoot\login.ps1"

Function removeNSG($NsgName)
{
    $NSG = Get-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME -Name $NsgName -ErrorAction SilentlyContinue
    if ($NSG)
    {
         $NSG = Remove-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME -Name $NsgName
    }
}

Function removeSubNet($SubnetName, $virtualNetwork)
{
    $Subnet = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $virtualNetwork -ErrorAction SilentlyContinue
    if ($Subnet)
    {
        $Subnet = Remove-AzVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $virtualNetwork
    }
    return $Subnet
}


$virtualNetwork  = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction SilentlyContinue
if ($virtualNetwork)
{

    removeSubNet -SubnetName $FrontEndSubnetName -virtualNetwork $virtualNetwork
    removeSubNet -SubnetName $BackendSubnetName -virtualNetwork $virtualNetwork
  
    Remove-AzVirtualNetwork -ResourceGroupName $RESOURCEGROUP_NAME -Name $VirtualNetworkName
}

removeNsg -NsgName $FrontEndNSGName
removeNsg -NsgName $BackEndNSGName



