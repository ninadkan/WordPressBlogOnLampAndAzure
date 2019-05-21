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

$publicIpName="blogSiteIpAddress$Version"
$dnsPrefix="ninadkanthi$Version"
$virtualMachineNameFrontEnd="linuxwebfrontend$Version"
$virtualMachineNameBackEnd="linuxwebfrontend$Version"

$RecordSetName = "blogs"

$VirtualNetworkName = "blogs-vnet"

$FrontEndSubnetName = "blogs-subnet-frontend"
$BackendSubnetName = "blogs-subnet-backend"

$FrontEndNSGName = "blogs-nsg-frontend"
$BackEndNSGName = "blogs-nsg-backend"

$NwInterfaceFront1 = "NetworkInterface-Front-1"
$NwInterfaceFront2 = "NetworkInterface-Front-2"
$NwInterfaceBack1 = "NetworkInterface-Back-1"
$NwInterfaceBack2 = "NetworkInterface-Back-2"

$LoadBalancerName ="blogs-load-balancer"

$frontEndLBPoolName = "frontEndLoadBlanacerPool"
$backEndLBPoolName = "BackEndLoadBalancerPool"
$healthProbeName = "LoadBalancerHealthProbe"
$loadBalancerRuleName = "LoadBalancerRule"

$natRuleName1 = "LoadBalancerNATRule1"
$natRuleName2 = "LoadBalancerNATRule2"

$AvailabilitySetName = "blog-AvailabilitySet"

$FrontEndVMName = "blogFrontEndVM"
$BackEndVMName = "blogBackEndVM"









