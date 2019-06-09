set user=webuser
set ipAddress=52.151.106.36

echo %user%@%ipAddress%

scp .\*.* %user%@%ipAddress%:.
echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"



