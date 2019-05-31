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
        
    $ipAddress = $temporaryIP.IpAddress

    $nic = Get-AzNetworkInterface `
            -Name $nicName `
            -ResourceGroupName $RESOURCEGROUP_NAME `
               

    if ($nic)
    {
        Write-Host -ForegroundColor Green `
            "create a new network interface  '$nicName'... "
        Set-AzNetworkInterfaceIpConfig `
            -Name $nic.IpConfigurations[0].Name `
            -NetworkInterface $nic `
            -Subnet $nic.IpConfigurations[0].Subnet `
            -PrivateIpAddress $nic.IpConfigurations[0].PrivateIpAddress `
            -LoadBalancerBackendAddressPool $nic.IpConfigurations[0].LoadBalancerBackendAddressPools `
            -LoadBalancerInboundNatRule $nic.IpConfigurations[0].LoadBalancerInboundNatRules `
            -Primary `
            -PublicIpAddress $temporaryIP 
           
        # Will this work? I am creating a new NIC with previous name
        #$nic = New-AzNetworkInterface `
        #    -Name $nicName `
        #    -ResourceGroupName $RESOURCEGROUP_NAME `
        #    -Location $LOCATION `
        #    -SubnetId $Subnet.Id `
        #    -NetworkSecurityGroupId $NSG.Id `
        #    -PublicIpAddressId $temporaryIP.Id

        #Set-AzNetworkInterfaceIpConfig `
        #    -Name $nic.IpConfigurations[0].Name `
        #    -NetworkInterface $nic `
            

        #$nic.Primary = $false
        Set-AzNetworkInterface -NetworkInterface $nic

            
        #$nwInterface = Get-AzNetworkInterface `
        #    -Name $originalNetworkInterfaceName `
        #    -ResourceGroupName $RESOURCEGROUP_NAME
        #$nwInterface.Primary = $true
        #Set-AzNetworkInterface -NetworkInterface $nwInterface

        #Add-AzVMNetworkInterface `
        #    -VM $VM `
        #    -NetworkInterface $nic 

        #$VM.NetworkProfile.NetworkInterfaces[0].Primary = $true; 
                
                
        #Update-AzVM `
        #    -ResourceGroupName $RESOURCEGROUP_NAME `
        #    -VM $VM

    }
    Write-Host -ForegroundColor Cyan "Temporary IP address = '$ipAddress', NIC = '$nicName'"
}


Function openRDPPortForNSGs($NsgName)
{

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
         

        if (-not $ruleExist)
        {
            # Add rdpRule to the collection
            Add-AzNetworkSecurityRuleConfig `
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

            Set-AzNetworkSecurityGroup -NetworkSecurityGroup $NSG

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


#Stop-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndVMName1
#Stop-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndVMName2
#Stop-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $BackEndVMName


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


#Start-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndVMName1
#Start-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $FrontEndVMName2
#Start-AzVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $BackEndVMName


