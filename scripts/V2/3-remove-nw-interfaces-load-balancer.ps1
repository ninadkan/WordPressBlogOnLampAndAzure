. "$PSScriptRoot\login.ps1"


Function removeNetworkInterface($networkInterfaceName )
{
    $nwInterface = Get-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction SilentlyContinue
    if ($nwInterface)
    {
        Remove-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $RESOURCEGROUP_NAME
    }
}

$loadBalancer = Get-AzLoadBalancer -ResourceGroupName $RESOURCEGROUP_NAME -Name $LoadBalancerName -ErrorAction SilentlyContinue
if ($loadBalancer)
{
    $natrule1 = Get-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer -Name $natRuleName1 -ErrorAction SilentlyContinue
    if ($natrule1)
    {
        Remove-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer -Name $natRuleName1
    }

    $natrule2 = Get-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer -Name $natRuleName2 -ErrorAction SilentlyContinue
    if ($natrule2)
    {
        Remove-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer -Name $natRuleName2
    }

    $loadBalancerRule = Get-AzLoadBalancerRuleConfig -Name $loadBalancerRuleName -LoadBalancer $loadBalancer -ErrorAction SilentlyContinue
    if ($loadBalancerRule)
    {
        Remove-AzLoadBalancerRuleConfig -Name $loadBalancerRuleName -LoadBalancer $loadBalancer
    }

    $healthProbe = Get-AzLoadBalancerProbeConfig -Name $healthProbeName -LoadBalancer $loadBalancer -ErrorAction SilentlyContinue
    if ($healthProbe)
    {
        Remove-AzLoadBalancerProbeConfig -Name $healthProbeName -LoadBalancer $loadBalancer
    }

    $frontEndLBPool = Get-AzLoadBalancerFrontendIpConfig -LoadBalancer $loadBalancer -Name $frontEndLBPoolName -ErrorAction SilentlyContinue
    if ($frontEndLBPool)
    {
        $frontEndLBPool = Remove-AzLoadBalancerFrontendIpConfig -LoadBalancer $loadBalancer -Name $frontEndLBPoolName     
    }

    $backEndLBPool = Get-AzLoadBalancerBackendAddressPoolConfig -LoadBalancer $loadBalancer -Name $backEndLBPoolName -ErrorAction SilentlyContinue
    if($backEndLBPool)
    {
        $backEndLBPool = Remove-AzLoadBalancerBackendAddressPoolConfig -Name $backEndLBPoolName -LoadBalancer $loadBalancer
    }

    # remove the load balancer
    Remove-AzLoadBalancer -ResourceGroupName $RESOURCEGROUP_NAME -Name $LoadBalancerName
}

# remove the network interfaces
removeNetworkInterface -networkInterfaceName $NwInterfaceFront1
removeNetworkInterface -networkInterfaceName $NwInterfaceFront2
removeNetworkInterface -networkInterfaceName $NwInterfaceBack1
removeNetworkInterface -networkInterfaceName $NwInterfaceBack2
