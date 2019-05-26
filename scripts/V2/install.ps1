. "$PSScriptRoot\login.ps1"

# creates eveything in one go
# 1. create public IP and connect with DNS
. "$PSScriptRoot\1-create-public-IP-connect-DNS.ps1"

# 2. create Network components. VNET, subnets and NSGs
. "$PSScriptRoot\2-create-network.ps1"

# 3. create availability set and storage accounts
. "$PSScriptRoot\3-create-availability-set-storage.ps1"

# 4. Create front-end VMs, Back-end VMs
. "$PSScriptRoot\frontend-webserver\deploy.ps1"

# 6. Configure Back-end VMS

# 7. Configure Front-end VMs

# 8. Test HTTP Connection

# 9. Install and Test HTTPs connections

# 10. Install and Test Load Balancer 

# 11. Final Thoughts ....








