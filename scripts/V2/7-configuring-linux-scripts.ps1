. "$PSScriptRoot\login.ps1"



Function UpdateLine([string] $line, [string] $value)
{
    $index = $line.IndexOf('=')
    $delimiter = ''

    if ($index -ige 0)
    {
        $line = $line.Substring(0, $index+1) + $value
    }
    return $line
}

Function UpdateTextFile([string] $configFilePath, [System.Collections.HashTable] $dictionary)
{
    $lines = Get-Content $configFilePath
    $index = 0
    while($index -lt $lines.Length)
    {
        $line = $lines[$index]
        foreach($key in $dictionary.Keys)
        {
            
            if ($line.Contains($key))
            {
               $lines[$index] = UpdateLine $line $dictionary[$key]
            }
        }
        $index++
    }
    Set-Content -Path $configFilePath -Value $lines -Force
}


function updateFilesWithIpAddress($IpAddressName, [string] $configFilePath, [string]$key)
{
    #create a temporary IP address for the webserver to connect and upload
    $temporaryIP = Get-AzPublicIpAddress `
        -Name $IpAddressName `
        -ResourceGroupName $RESOURCEGROUP_NAME
    $ipaddr=$temporaryIP.IpAddress

    $dictionary = @{ $key = $ipaddr};

    UpdateTextFile -configFilePath $configFilePath -dictionary $dictionary

    Write-Host "ssh webuser@$ipaddr -p 22"
}


$dbserver = "$PSScriptRoot\dbserver\scopy.bat"
$webservr = "$PSScriptRoot\webuser\scopy.bat"
$key = "set ipAddress"
$key2 = "set ipAddress2"

updateFilesWithIpAddress -IpAddressName $temporaryIPAddrFrontEnd1Name -configFilePath $webservr -key $key 
updateFilesWithIpAddress -IpAddressName $temporaryIPAddrFrontEnd2Name -configFilePath $webservr -key $key2 
updateFilesWithIpAddress -IpAddressName $temporaryIPAddrBackEndName -configFilePath $dbserver -key $key 




