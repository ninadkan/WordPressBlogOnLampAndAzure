. "$PSScriptRoot\login.ps1"

Function stopLinuxVM($VMName)
{
    $vm = Get-AzVM –Name $VMName `
        –ResourceGroupName $RESOURCEGROUP_NAME `
        -ErrorAction SilentlyContinue
    if ($vm)
    { 
        Stop-AzVM `
            -Name $VMName `
            -ResourceGroupName $RESOURCEGROUP_NAME
    }
    else
    {
        Write-Warning "VM not found for removing '$VMName'"
    }
}


stopLinuxVM -VMName $FrontEndVMName1
stopLinuxVM -VMName $FrontEndVMName2
stopLinuxVM -VMName $BackEndVMName

