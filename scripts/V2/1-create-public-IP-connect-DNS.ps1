. "$PSScriptRoot\login.ps1"


$publicIp = Get-AzPublicIpAddress `
    -Name $publicIpName `
    -ResourceGroupName $RESOURCEGROUP_NAME `
    -ErrorAction SilentlyContinue

if (!$publicIp)
{
    Write-Host -ForegroundColor Green "create a new static IP address ... ";
    $publicIp = New-AzPublicIpAddress  -Name $publicIpName `
        -ResourceGroupName $RESOURCEGROUP_NAME -AllocationMethod Static `
        -DomainNameLabel $dnsPrefix -Location $LOCATION -Sku "Standard"
}
else
{
    $addr = $publicIp.IpAddress
    Write-Host -ForegroundColor Cyan "static IP address already exists = '$addr'";
}









