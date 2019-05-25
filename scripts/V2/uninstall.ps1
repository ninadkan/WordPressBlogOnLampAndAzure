. "$PSScriptRoot\login.ps1"

#removes everythin from Azure
# 3. create availability set and storage accounts
. "$PSScriptRoot\3-remove-availability-set-storage.ps1"

# 2. create Network components. VNET, subnets and NSGs
. "$PSScriptRoot\2-remove-network.ps1"

# 1. Remove the public IP connection
. "$PSScriptRoot\3-remove-availability-set-storage.ps1"


