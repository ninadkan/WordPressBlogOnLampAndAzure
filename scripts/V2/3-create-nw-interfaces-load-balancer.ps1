. "$PSScriptRoot\login.ps1"

Function createNetworkInterface($networkInterfaceName, $Subnet, $NsgGroup, $virtualNetwork, $publicIp )
{
    $nwInterface = Get-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction SilentlyContinue
    if (-not $nwInterface)
    {
        $nwInterface = New-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $RESOURCEGROUP_NAME -Location $LOCATION -SubnetId $Subnet.Id -NetworkSecurityGroupId $NsgGroup.Id
    }
    return $nwInterface
}

$publicIp = Get-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction Stop
$virtualNetwork  = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction Stop

$frontEndSubnet = Get-AzVirtualNetworkSubnetConfig -Name $FrontEndSubnetName -VirtualNetwork $virtualNetwork -ErrorAction Stop
$backendSubnet = Get-AzVirtualNetworkSubnetConfig -Name $BackendSubnetName -VirtualNetwork $virtualNetwork -ErrorAction Stop

$frontendNSG = Get-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndNSGName -ErrorAction Stop
$backendNSG = Get-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME -Name $BackEndNSGName -ErrorAction Stop

$nwf1 = createNetworkInterface -networkInterfaceName $NwInterfaceFront1 -virtualNetwork $virtualNetwork -Subnet $frontEndSubnet -NsgGroup $frontendNSG -publicIp $publicIp
$nwf2 = createNetworkInterface -networkInterfaceName $NwInterfaceFront2 -virtualNetwork $virtualNetwork -Subnet $frontEndSubnet -NsgGroup $frontendNSG -publicIp $publicIp
$nwb1 = createNetworkInterface -networkInterfaceName $NwInterfaceBack1 -virtualNetwork $virtualNetwork -Subnet $backendSubnet -NsgGroup $backendNSG -publicIp $publicIp
$nwb2 = createNetworkInterface -networkInterfaceName $NwInterfaceBack2 -virtualNetwork $virtualNetwork -Subnet $backendSubnet -NsgGroup $backendNSG -publicIp $publicIp

# Lets create the load balancer as well here

$loadBalancer = Get-AzLoadBalancer -ResourceGroupName $RESOURCEGROUP_NAME -Name $LoadBalancerName -ErrorAction SilentlyContinue

if (-not $loadBalancer)
{
    # imagine that none of the other constructs are created!!!
    $loadBalancer = New-AzLoadBalancer -Sku "Standard" -ResourceGroupName $RESOURCEGROUP_NAME `
                                                        -Name $LoadBalancerName `
                                                        -Location $LOCATION
                                                        
}


if ($loadBalancer)
{

    $frontEndLBPool = Get-AzLoadBalancerFrontendIpConfig -LoadBalancer $loadBalancer -Name $frontEndLBPoolName -ErrorAction SilentlyContinue
    if (-not $frontEndLBPool)
    {
        $frontEndLBPool = Add-AzLoadBalancerFrontendIpConfig -LoadBalancer $loadBalancer -Name $frontEndLBPoolName -PublicIpAddress  $publicIp 
        Set-AzLoadBalancer -LoadBalancer $loadBalancer   
    }

    $backEndLBPool = Get-AzLoadBalancerBackendAddressPoolConfig -LoadBalancer $loadBalancer -Name $backEndLBPoolName -ErrorAction SilentlyContinue
    if(-not $backEndLBPool)
    {
        $backEndLBPool = Add-AzLoadBalancerBackendAddressPoolConfig -Name $backEndLBPoolName -LoadBalancer $loadBalancer
        Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    $healthProbe = Get-AzLoadBalancerProbeConfig -Name $healthProbeName -LoadBalancer $loadBalancer -ErrorAction SilentlyContinue
    if (-not $healthProbe)
    {
        $healthProbe = Add-AzLoadBalancerProbeConfig -Name $healthProbeName -LoadBalancer $loadBalancer  -Protocol Http -Port 80 -IntervalInSeconds 20 -ProbeCount 2 -RequestPath "dummyCheck.html"
        Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    $loadBalancerRule = Get-AzLoadBalancerRuleConfig -Name $loadBalancerRuleName -LoadBalancer $loadBalancer -ErrorAction SilentlyContinue
    if (-not $loadBalancerRule)
    {
        $loadBalancerRule = Add-AzLoadBalancerRuleConfig -LoadBalancer $loadBalancer -Name $loadBalancerRuleName -FrontendPort 80 `
                            -Protocol Tcp -BackendPort 80 `
                            -Probe $healthProbe.Probes `
                            -FrontendIpConfiguration $frontEndLBPool `
                            -BackendAddressPool $backEndLBPool
        Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    $natrule1 = Get-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer -Name $natRuleName1 -ErrorAction SilentlyContinue
    if (-not $natrule1)
    {
        $natrule1 = Add-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer `
        -Name $natRuleName1 `
        -FrontendIpConfiguration $frontEndLBPool `
        -Protocol tcp `
        -FrontendPort 4221 `
        -BackendPort 3389
        Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    $natrule2 = Get-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer -Name $natRuleName2 -ErrorAction SilentlyContinue

    if (-not $natrule2)
    { 
        $natrule2 = Add-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer `
        -Name $natRuleName2 `
        -FrontendIpConfiguration $frontEndLBPool `
        -Protocol tcp `
        -FrontendPort 4222 `
        -BackendPort 3389
    }
    
    # And finally mother of all updates... fire
    Set-AzLoadBalancer -LoadBalancer $loadBalancer

}
else
{
    Write-Host -ForegroundColor Red "Error! Load Balancer '$LoadBalancerName' not found"
}











