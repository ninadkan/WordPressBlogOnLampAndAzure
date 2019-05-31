$RESOURCEGROUP_NAME="blog-rg"
$LOCATION="UK South"
$SUBSCRIPTION="ninadkanthi.co.uk"
$FQDN="blogs.$SUBSCRIPTION"
$Version="-v2"
$DNSNAME = "$SUBSCRIPTION"
#$SERVICEPLAN_NAME="WordPressHosting"
#$SERVICEPLAN_APPNAME="WordPressHostingWebApp"
#$HOSTNAME = "$SERVICEPLAN_APPNAME.azurewebsites.net"
# Following variables are double defined in the parameters file as well

$publicIpName="SitePublicIp$Version"
$temporaryIPAddressName="TemporaryIPAddresss"
$dnsPrefix="ninadkanthi$Version"
$virtualMachineNameFrontEnd="linuxwebfrontend$Version"
$virtualMachineNameBackEnd="linuxwebfrontend$Version"

$RecordSetName = "blogs"

$VirtualNetworkName = "site-vnet"

$FrontEndSubnetName = "subnet-frontend$Version"
$BackendSubnetName = "subnet-backend$Version"

$FrontEndNSGName = "nsg-frontend$Version"
$BackEndNSGName = "nsg-backend$Version"

$NwInterfaceFront1 = "NetworkInterface-Front-1"
$NwInterfaceFront2 = "NetworkInterface-Front-2"
$NwInterfaceBack1 = "NetworkInterface-Back-1"

#$SecondaryNwInterfaceFrontEnd1Name = "Secondary-NetworkInterface-Front-1"
#$SecondaryNwInterfaceFrontEnd2Name = "Secondary-NetworkInterface-Front-2"
#$SecondaryNwInterfaceBackEnd = "Secondary-NetworkInterface-Back-1"

$LoadBalancerName ="load-balancer$Version"

$frontEndLBPoolName = "frontEndLoadBlanacerPool"
$backEndLBPoolName = "BackEndLoadBalancerPool"
$healthProbeName = "LoadBalancerHealthProbe"
$loadBalancerRuleName = "LoadBalancerRule"

$natRuleName1 = "LoadBalancerNATRule1"

$AvailabilitySetName = "AvailabilitySet$Version"

$FrontEndVMName1 = "frontendwebserver1"
$FrontEndVMName2 = "frontendwebserver2"
$BackEndVMName = "backend-databaseserver$Version"

$commonStorageAccountName = "blogsstorageaccount"

$temporaryIPAddrFrontEnd1Name="TemporaryIPAddressFrontEnd1"
$temporaryIPAddrFrontEnd2Name="TemporaryIPAddressFrontEnd2"
$temporaryIPAddrBackEndName="TemporaryIPAddressBackEnd"


$rdpSecurityRuleName = "rdp-nsg-rule"
$httpSecurityRuleName = "http-nsg-rule"
$httpsSecurityRuleName = "https-nsg-rule"

$WebUserName = "webuser"













