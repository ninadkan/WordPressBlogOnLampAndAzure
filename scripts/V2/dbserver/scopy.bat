set user=webuser
set ipAddress=51.145.126.6

echo %user%@%ipAddress%

scp .\*.* %user%@%ipAddress%:.
echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"



