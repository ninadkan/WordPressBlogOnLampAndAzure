. "$PSScriptRoot\login.ps1"

# 1. create public IP and connect with DNS
. "$PSScriptRoot\1-create-public-IP-connect-DNS.ps1"

# 2. create Network components. VNET, subnets and NSGs
. "$PSScriptRoot\2-create-network.ps1"





