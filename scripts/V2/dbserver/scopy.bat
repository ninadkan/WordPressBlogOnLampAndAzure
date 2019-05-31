set user=webuser
set ipAddress=51.145.125.73

echo %user%@%ipAddress%

scp .\*.* %user%@%ipAddress%:.
echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"



