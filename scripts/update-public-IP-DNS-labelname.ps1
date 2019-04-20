. "$PSScriptRoot\login.ps1"


$RunningState=((Get-AzureRmVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $virtualMachineName -Status).Statuses[1]).Code
if ($RunningState -eq "Powerstate/Running")
{
    Write-Host "Stopping VM $virtualMachineName";
    $StoppedStatus= Stop-AzureRmVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $virtualMachineName
}

Write-Host "Updating new static IP address for $virtualMachineName";
$publicIp = New-AzureRmPublicIpAddress  -Name $publicIpName -ResourceGroupName $RESOURCEGROUP_NAME -AllocationMethod Static -DomainNameLabel $dnsPrefix -Location $LOCATION

Write-Host "Starting $virtualMachineName ... ";
Start-AzureRmVM -ResourceGroupName $RESOURCEGROUP_NAME -Name $virtualMachineName

Write-Host "... done";




