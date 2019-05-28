. "$PSScriptRoot\login.ps1"





Function AttachNicAndPublicIP($NicName, $PublicIPAddressName)
{
    $vnet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $RESOURCEGROUP_NAME
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $FrontEndSubnetName -VirtualNetwork $vnet
    $nic = Get-AzNetworkInterface -Name $NicName -ResourceGroupName $RESOURCEGROUP_NAME
    $pip = Get-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $RESOURCEGROUP_NAME

    $ipConfig = Get-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic

    $nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -PublicIpAddress $pip -Subnet $subnet -Primary
    $nic.EnableIPForwarding = 1
    $nic | Set-AzNetworkInterface
}

Function DetachNICAndPublicIP($NicName, $PublicIPAddressName)
{
    $vnet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $RESOURCEGROUP_NAME
    $subnet = Get-AzVirtualNetworkSubnetConfig -Name $FrontEndSubnetName -VirtualNetwork $vnet
    $nic = Get-AzNetworkInterface -Name $NicName -ResourceGroupName $RESOURCEGROUP_NAME
    $pip = Get-AzPublicIpAddress -Name $PublicIPAddressName -ResourceGroupName $RESOURCEGROUP_NAME


    $ipConfig = Get-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic
    #$nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -Subnet $subnet  -Primary
    Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic -Subnet $subnet -Primary
    $nic | Set-AzNetworkInterface
}


#AttachNicAndPublicIP -NicName $NwInterfaceFront1 -PublicIPAddressName $publicIpName
#DetachNICAndPublicIP -NicName $NwInterfaceFront1 -PublicIPAddressName $publicIpName

#AttachNicAndPublicIP -NicName $NwInterfaceFront2 -PublicIPAddressName $publicIpName
DetachNICAndPublicIP -NicName $NwInterfaceFront2 -PublicIPAddressName $publicIpName







