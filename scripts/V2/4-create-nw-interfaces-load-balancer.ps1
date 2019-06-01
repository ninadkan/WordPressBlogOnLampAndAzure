. "$PSScriptRoot\login.ps1"$

Function createNetworkInterface($networkInterfaceName, # name of NIC
                $Subnet, # Subnet where the NIC will be plugged in
                $NsgGroup, # NSG where the created NIC will be placed nder
                $backEndPoolName = $null , # load balancer back-end pool, 
                                           #if specified, NIC is added there
                $lb =$null, # name of load balancer, used to get the NST rule
                $natRule =$null) # name of the NAT rule
{
    $nwInterface = Get-AzNetworkInterface `
        -Name $networkInterfaceName `
        -ResourceGroupName $RESOURCEGROUP_NAME `
        -ErrorAction SilentlyContinue
    if (-not $nwInterface)
    {
        Write-Host  `
            -ForegroundColor Green  `
            "Creating Network Interface '$networkInterfaceName'"
        if ($backEndPoolName)
        {

            $tempPool = Get-AzLoadBalancerBackendAddressPoolConfig `
                -LoadBalancer $lb `
                -Name $backEndPoolName
                
            if ($natRule)
            {
                $nr = Get-AzLoadBalancerInboundNatRuleConfig `
                    -LoadBalancer $lb `
                    -Name $natRuleName1
   
                # create NIC with NAT Rule + Back-end Pool + Subnet + NSG
                $nwInterface = New-AzNetworkInterface `
                    -Name $networkInterfaceName `
                    -ResourceGroupName $RESOURCEGROUP_NAME `
                    -Location $LOCATION `
                    -SubnetId $Subnet.Id `
                    -NetworkSecurityGroupId $NsgGroup.Id `
                    -LoadBalancerBackendAddressPoolId $tempPool.Id `
                    -LoadBalancerInboundNatRuleId $nr.Id `
                    -EnableIPForwarding 
            }
            else
            {
                # create NIC with Back-end Pool + Subnet + NSG
                $nwInterface = New-AzNetworkInterface `
                    -Name $networkInterfaceName `
                    -ResourceGroupName $RESOURCEGROUP_NAME `
                    -Location $LOCATION `
                    -SubnetId $Subnet.Id `
                    -NetworkSecurityGroupId $NsgGroup.Id `
                    -LoadBalancerBackendAddressPoolId $tempPool.Id `
                    -EnableIPForwarding 
            }
        }
        else
        {
            # create NIC with Subnet + NSG
            $nwInterface = New-AzNetworkInterface `
                -Name $networkInterfaceName `
                -ResourceGroupName $RESOURCEGROUP_NAME `
                -Location $LOCATION `
                -SubnetId $Subnet.Id `
                -NetworkSecurityGroupId $NsgGroup.Id `
                -EnableIPForwarding 
                
        }
    }

    $nwInterface.Primary = $true
    $dummy = Set-AzNetworkInterface -NetworkInterface $nwInterface

    return $nwInterface
}

$publicIp = Get-AzPublicIpAddress `
    -Name $publicIpName `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -ErrorAction Stop
$virtualNetwork  = Get-AzVirtualNetwork `
    -Name $VirtualNetworkName `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -ErrorAction Stop

$frontEndSubnet = Get-AzVirtualNetworkSubnetConfig `
    -Name $FrontEndSubnetName `
    -VirtualNetwork $virtualNetwork `
    -ErrorAction Stop
$backendSubnet = Get-AzVirtualNetworkSubnetConfig `
    -Name $BackendSubnetName `
    -VirtualNetwork $virtualNetwork `
    -ErrorAction Stop

$frontendNSG = Get-AzNetworkSecurityGroup `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -Name $FrontEndNSGName `
    -ErrorAction Stop
$backendNSG = Get-AzNetworkSecurityGroup `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -Name $BackEndNSGName `
    -ErrorAction Stop
    
# Lets create the load balancer as well here

$loadBalancer = Get-AzLoadBalancer `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -Name $LoadBalancerName `
    -ErrorAction SilentlyContinue

if (-not $loadBalancer)
{
    # imagine that none of the other constructs are created!!!
    Write-Host  `
        -ForegroundColor Green  `
        "Creating Load Balancer '$LoadBalancerName'"

    $loadBalancer = New-AzLoadBalancer `
        -Sku "Standard" `
        -ResourceGroupName $RESOURCEGROUP_NAME `
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
        #create the front end Pool with $publicIP added

        Write-Host  `
        -ForegroundColor Green  `
        "Creating Front end '$frontEndLBPoolName'"

        $frontEndLBPool = Add-AzLoadBalancerFrontendIpConfig `
            -LoadBalancer $loadBalancer `
            -Name $frontEndLBPoolName `
            -PublicIpAddress  $publicIp 
        $dummy = Set-AzLoadBalancer -LoadBalancer $loadBalancer   
    }

    $backEndLBPool = Get-AzLoadBalancerBackendAddressPoolConfig `
        -LoadBalancer $loadBalancer `
        -Name $backEndLBPoolName `
        -ErrorAction SilentlyContinue
    if(-not $backEndLBPool)
    {

        Write-Host  `
        -ForegroundColor Green  `
        "Creating Backend Pool '$backEndLBPoolName'"

        $backEndLBPool = Add-AzLoadBalancerBackendAddressPoolConfig `
            -Name $backEndLBPoolName `
            -LoadBalancer $loadBalancer
        $dummy = Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    $healthProbe = Get-AzLoadBalancerProbeConfig `
        -Name $healthProbeName `
        -LoadBalancer $loadBalancer `
        -ErrorAction SilentlyContinue
    if (-not $healthProbe)
    {

        Write-Host  `
        -ForegroundColor Green  `
        "Creating health probe '$healthProbeName'"

        $healthProbe = Add-AzLoadBalancerProbeConfig `
            -Name $healthProbeName `
            -LoadBalancer $loadBalancer  `
            -Protocol Https `
            -Port 443 `
            -IntervalInSeconds 20 `
            -ProbeCount 2 `
            -RequestPath "/readme.html"
        $dummy =  Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    $loadBalancerRule = Get-AzLoadBalancerRuleConfig `
        -Name $loadBalancerRuleName `
        -LoadBalancer $loadBalancer `
        -ErrorAction SilentlyContinue
    if (-not $loadBalancerRule)
    {

        Write-Host  `
        -ForegroundColor Green  `
        "Creating balancer rule '$loadBalancerRuleName'"

        $var = $healthProbe.Probes

        # Hack because the type returned by 
        # 'Add-AzLoadBalancerProbeConfig' and 
        # 'Get-AzLoadBalancerProbeConfig' is different! 
        #Write-Host $healthProbe.Probes.GetType().FullName
        if ($healthProbe.Probes.GetType().FullName.ToLower().Contains("System.Collections.Generic.List".ToLower()))
        {
            $var = $healthProbe.Probes[0]
        }

        $loadBalancerRule = Add-AzLoadBalancerRuleConfig `
            -LoadBalancer $loadBalancer `
            -Name $loadBalancerRuleName `
            -FrontendPort 443 `
            -Protocol Tcp `
            -BackendPort 443 `
            -Probe $var `
            -FrontendIpConfiguration $frontEndLBPool.FrontendIpConfigurations[0] `
            -BackendAddressPool $backEndLBPool.BackendAddressPools[0]
        $dummy = Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    $natrule1 = Get-AzLoadBalancerInboundNatRuleConfig `
        -LoadBalancer $loadBalancer `
        -Name $natRuleName1 `
        -ErrorAction SilentlyContinue
    if (-not $natrule1)
    {

        Write-Host  `
        -ForegroundColor Green  `
        "Creating nat rule 1 '$natRuleName1'"


        $natrule1 = Add-AzLoadBalancerInboundNatRuleConfig `
        -LoadBalancer $loadBalancer `
        -Name $natRuleName1 `
        -FrontendIpConfiguration $frontEndLBPool.FrontendIpConfigurations[0] `
        -Protocol tcp `
        -FrontendPort 80 `
        -BackendPort 80

        $dummy = Set-AzLoadBalancer -LoadBalancer $loadBalancer
    }

    
    # And finally combination of all updates... fire
    $dummy = Set-AzLoadBalancer -LoadBalancer $loadBalancer

    # create the network interfaces now.
    $nwf1 = createNetworkInterface `
        -networkInterfaceName $NwInterfaceFront1 `
        -Subnet $frontEndSubnet `
        -NsgGroup $frontendNSG `
        -backEndPoolName $backEndLBPoolName `
        -lb $loadBalancer `
        -natRule $natRuleName1

  

    $nwf2 = createNetworkInterface `
        -networkInterfaceName $NwInterfaceFront2 `
        -Subnet $frontEndSubnet `
        -NsgGroup $frontendNSG `
        -backEndPoolName $backEndLBPoolName `
        -lb $loadBalancer
        

    $nwb1 = createNetworkInterface `
        -networkInterfaceName $NwInterfaceBack1 `
        -Subnet $backendSubnet `
        -NsgGroup $backendNSG


}
else
{
    Write-Host -ForegroundColor Red "Error! Load Balancer '$LoadBalancerName' not found"
}











