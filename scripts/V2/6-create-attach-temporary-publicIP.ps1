. "$PSScriptRoot\login.ps1"

Function createAttach_PublicIP_NIC($IpAddressName, `
                        $nicName                
                        )
{
    #create a temporary public IP address
    $temporaryIP = Get-AzPublicIpAddress `
        -Name $IpAddressName `
        -ResourceGroupName $RESOURCEGROUP_NAME `
        -ErrorAction SilentlyContinue

    if (-not $temporaryIP)
    {
        Write-Host -ForegroundColor Green `
            "create a new static IP address '$IpAddressName'... "
        $temporaryIP = New-AzPublicIpAddress  `
                            -Name $IpAddressName `
                            -ResourceGroupName $RESOURCEGROUP_NAME `
                            -AllocationMethod Static `
                            -Location $LOCATION `
                            -Sku "Standard"
    }
        
    
    $nic = Get-AzNetworkInterface `
            -Name $nicName `
            -ResourceGroupName $RESOURCEGROUP_NAME `
               
    if ($nic)
    {
        Write-Host -ForegroundColor Green `
            "Attaching the created public IP to NIC '$nicName'... "
        $d =Set-AzNetworkInterfaceIpConfig `
            -Name $nic.IpConfigurations[0].Name `
            -NetworkInterface $nic `
            -Subnet $nic.IpConfigurations[0].Subnet `
            -PrivateIpAddress $nic.IpConfigurations[0].PrivateIpAddress `
            -LoadBalancerBackendAddressPool $nic.IpConfigurations[0].LoadBalancerBackendAddressPools `
            -LoadBalancerInboundNatRule $nic.IpConfigurations[0].LoadBalancerInboundNatRules `
            -Primary `
            -PublicIpAddress $temporaryIP 
         $d = Set-AzNetworkInterface -NetworkInterface $nic
    }
    $ipAddress = $temporaryIP.IpAddress
    Write-Host -ForegroundColor Cyan "Temporary IP address = '$ipAddress', NIC = '$nicName'"
}


Function openRDPPortForNSGs($NsgName)
{
    $NSG = Get-AzNetworkSecurityGroup `
        -ResourceGroupName $RESOURCEGROUP_NAME `
        -Name $NsgName
    if ($NSG)
    {
        Write-Host -ForegroundColor Green "creating new rule for '$NsgName' ... "

        $existingRules = $NSG.SecurityRules
        $ruleExist = $false

        ForEach ($existingrule in $existingRules) { 
            Write-Host $existingrule.Name
            If ($existingrule.Name.StartsWith($rdpSecurityRuleName))
            {
               $ruleExist = $true
               break 
            } 
        }

        if (-not $ruleExist)
        {
            # Add rdpRule to the collection
            $d= Add-AzNetworkSecurityRuleConfig `
                -Access Allow `
                -Direction Inbound `
                -Priority 1050 `
                -Name $rdpSecurityRuleName `
                -NetworkSecurityGroup $NSG `
                -Protocol Tcp `
                -SourcePortRange * `
                -DestinationPortRange 22 `
                -SourceAddressPrefix * `
                -DestinationAddressPrefix *
            $d = Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSG
        }
        else
        {
            Write-Warning ("NSG '$NsgName' already contains rule - '$rdpSecurityRuleName' ")
        }
    }
    else
    {
        Write-Warning ("NSG Does not exist - '$NsgName'")
    }
    return $NSG
}

createAttach_PublicIP_NIC `
    -IpAddressName $temporaryIPAddrFrontEnd1Name `
    -nicName $NwInterfaceFront1
    
createAttach_PublicIP_NIC `
    -IpAddressName $temporaryIPAddrFrontEnd2Name `
    -nicName $NwInterfaceFront2 
    
createAttach_PublicIP_NIC `
    -IpAddressName $temporaryIPAddrBackEndName `
    -nicName $NwInterfaceBack1
    
openRDPPortForNSGs -NsgName $FrontEndNSGName
openRDPPortForNSGs -NsgName $BackEndNSGName




