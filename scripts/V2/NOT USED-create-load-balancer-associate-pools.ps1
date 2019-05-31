. "$PSScriptRoot\login.ps1"

$publicIp = Get-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction Stop
#$virtualNetwork  = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction Stop

#$frontEndSubnet = Get-AzVirtualNetworkSubnetConfig -Name $FrontEndSubnetName -VirtualNetwork $virtualNetwork -ErrorAction Stop
#$backendSubnet = Get-AzVirtualNetworkSubnetConfig -Name $BackendSubnetName -VirtualNetwork $virtualNetwork -ErrorAction Stop

#$frontendNSG = Get-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndNSGName -ErrorAction Stop
#$backendNSG = Get-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME -Name $BackEndNSGName -ErrorAction Stop

#Function associateNetworkInterfaceWithBackendPool($networkInterfaceName)
#{
#    $nwInterface = Get-AzNetworkInterface -Name $networkInterfaceName -ResourceGroupName $RESOURCEGROUP_NAME -ErrorAction SilentlyContinue
#    if ($nwInterface)
#    {
#        New-AzNetworkInterface -  
#       
#    }
#}


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

    $frontEndLBPool = Get-AzLoadBalancerFrontendIpConfig `
        -LoadBalancer $loadBalancer `
        -Name $frontEndLBPoolName `
        -ErrorAction SilentlyContinue
    if (-not $frontEndLBPool)
    {
        $frontEndLBPool = Add-AzLoadBalancerFrontendIpConfig `
            -LoadBalancer $loadBalancer `
            -Name $frontEndLBPoolName `
            -PublicIpAddress $publicIp 
        Set-AzLoadBalancer -LoadBalancer $loadBalancer   
    }

    $backEndLBPool = Get-AzLoadBalancerBackendAddressPoolConfig `
        -LoadBalancer $loadBalancer `
        -Name $backEndLBPoolName `
        -ErrorAction SilentlyContinue
    if(-not $backEndLBPool)
    {
        $backEndLBPool = Add-AzLoadBalancerBackendAddressPoolConfig `
            -Name $backEndLBPoolName `
            -LoadBalancer $loadBalancer
        Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    $healthProbe = Get-AzLoadBalancerProbeConfig `
        -Name $healthProbeName `
        -LoadBalancer $loadBalancer `
        -ErrorAction SilentlyContinue
    if (-not $healthProbe)
    {
        $healthProbe = Add-AzLoadBalancerProbeConfig `
            -Name $healthProbeName `
            -LoadBalancer $loadBalancer  `
            -Protocol Https `
            -Port 443 `
            -IntervalInSeconds 20 `
            -ProbeCount 2 `
            -RequestPath "/readme.html"
        Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    $loadBalancerRule = Get-AzLoadBalancerRuleConfig `
        -Name $loadBalancerRuleName `
        -LoadBalancer $loadBalancer `
        -ErrorAction SilentlyContinue
    if (-not $loadBalancerRule)
    {
       $loadBalancerRule = Add-AzLoadBalancerRuleConfig `
            -LoadBalancer $loadBalancer `
            -Name $loadBalancerRuleName `
            -FrontendPort 443 `
            -Protocol Tcp -BackendPort 443 `
            -Probe $healthProbe.Probes `
            -FrontendIpConfiguration $frontEndLBPool `
            -BackendAddressPool $backEndLBPool
        Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }




    $natrule1 = Get-AzLoadBalancerInboundNatRuleConfig `
        -LoadBalancer $loadBalancer `
        -Name $natRuleName1 `
        -ErrorAction SilentlyContinue
    if (-not $natrule1)
    {
        $natrule1 = Add-AzLoadBalancerInboundNatRuleConfig `
            -LoadBalancer $loadBalancer `
            -Name $natRuleName1 `
            -FrontendIpConfiguration $frontEndLBPool `
            -Protocol tcp `
            -FrontendPort 80 `
            -BackendPort 80
        Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    #$natrule2 = Get-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer -Name $natRuleName2 -ErrorAction SilentlyContinue

    #if (-not $natrule2)
    #{ 
    #    $natrule2 = Add-AzLoadBalancerInboundNatRuleConfig -LoadBalancer $loadBalancer `
    #    -Name $natRuleName2 `
    #    -FrontendIpConfiguration $frontEndLBPool `
    #    -Protocol tcp `
    #    -FrontendPort 4222 `
    #    -BackendPort 3389
    #}
    
    # And finally mother of all updates... fire
    Set-AzLoadBalancer -LoadBalancer $loadBalancer

}
else
{
    Write-Warning "Load balancer not found for '$VMName'"
}











