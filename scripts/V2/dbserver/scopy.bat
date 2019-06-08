set user=webuser
set ipAddress=40.81.153.27

echo %user%@%ipAddress%

scp .\*.* %user%@%ipAddress%:.
echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"



