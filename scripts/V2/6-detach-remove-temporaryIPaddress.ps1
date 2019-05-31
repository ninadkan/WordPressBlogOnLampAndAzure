. "$PSScriptRoot\login.ps1"

function removeTemporaryIPAddresses($TempIPAddressName, $nicName)
{

    $nic = Get-AzNetworkInterface `
            -Name $nicName `
            -ResourceGroupName $RESOURCEGROUP_NAME `
            -ErrorAction SilentlyContinue

    if ($nic)
    {
       Set-AzNetworkInterfaceIpConfig `
             -Name $nic.IpConfigurations[0].Name `
            -NetworkInterface $nic `
            -Subnet $nic.IpConfigurations[0].Subnet `
            -PrivateIpAddress $nic.IpConfigurations[0].PrivateIpAddress `
            -LoadBalancerBackendAddressPool $nic.IpConfigurations[0].LoadBalancerBackendAddressPools `
            -LoadBalancerInboundNatRule $nic.IpConfigurations[0].LoadBalancerInboundNatRules `
            -Primary 
 

        #$nic.Primary = $false
        Set-AzNetworkInterface -NetworkInterface $nic

        #remove the temporary publicIP address
        $temporaryIP = Get-AzPublicIpAddress `
            -Name $TempIPAddressName `
            -ResourceGroupName $RESOURCEGROUP_NAME `
            -ErrorAction SilentlyContinue
        if ($temporaryIP)
        {
            write-host -ForegroundColor Green `
            "Removing Temporary IP Address '$TempIPAddressName'"
            $temporaryIP = Remove-AzPublicIpAddress  `
                -Name $TempIPAddressName `
                -ResourceGroupName $RESOURCEGROUP_NAME 
        }
        else
        {
            Write-Warning "Temporary IP address '$TempIPAddressName' not found"
        }
    }
    else
    {
        Write-Warning "Nic not found - '$nicName' - removing Temporary IP address - '$TempIPAddressName'"
    }
}



#function detachPublicIPfromNIC($nicName)
#{
#    $nic = Get-AzNetworkInterface `
#            -Name $nicName `
#            -ResourceGroupName $RESOURCEGROUP_NAME
   #$nic.IpConfigurations[0].PublicIpAddress=$null
    #Set-AzNetworkInterface -NetworkInterface $nic 
#    $ipConfig = Get-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic
    #$nic | Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -Subnet $subnet  -Primary
#    Set-AzNetworkInterfaceIpConfig -Name $nic.IpConfigurations[0].Name -NetworkInterface $nic -Subnet $subnet -Primary
#    $nic | Set-AzNetworkInterface
#}


Function closeRDPPortForNSGs($NsgName)
{
    #$nsg = Get-AzureRmNetworkSecurityGroup
    #$nsg | Add-AzureRmNetworkSecurityRuleConfig 
    #$nsg | Set-AzureRmNetworkSecurityGroup

    $NSG = Get-AzNetworkSecurityGroup -ResourceGroupName $RESOURCEGROUP_NAME `
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

        if ($ruleExist)
        {
            Remove-AzNetworkSecurityRuleConfig -Name $rdpSecurityRuleName -NetworkSecurityGroup $NSG
            Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSG
        }
        else
        {
            Write-Warning ("NSG '$NsgName' Does not contain rule - '$rdpSecurityRuleName' ")
        }
    }
    else
    {
        Write-Warning ("NSG Does not exist - '$NsgName'")
    }
    return $NSG
}

# close RDP security gap
closeRDPPortForNSGs -NsgName $FrontEndNSGName
closeRDPPortForNSGs -NsgName $BackEndNSGName

# detach the public IP from the NICs
#detachPublicIPfromNIC -nicName $NwInterfaceBack1
#detachPublicIPfromNIC -nicName $NwInterfaceFront1
#detachPublicIPfromNIC -nicName $NwInterfaceFront2

# Remove Temporary IP addresses
removeTemporaryIPAddresses `
    -TempIPAddressName  $temporaryIPAddrFrontEnd1Name `
    -nicName $NwInterfaceFront1
removeTemporaryIPAddresses `
    -TempIPAddressName  $temporaryIPAddrFrontEnd2Name `
    -nicName $NwInterfaceFront2
removeTemporaryIPAddresses `
    -TempIPAddressName  $temporaryIPAddrBackEndName `
    -nicName $NwInterfaceBack1
# Backward compatibility
#removeTemporaryIPAddresses -TempIPAddressName  $temporaryIPAddressName

