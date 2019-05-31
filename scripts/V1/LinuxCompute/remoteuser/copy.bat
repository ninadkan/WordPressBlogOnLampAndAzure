set password=Dietpepsi-99!
set user=ninadk


set ipAddress=10.0.1.4
pscp -pw %password% .\*.sh %user%@%ipAddress%:.

set ipAddress=10.0.1.5
pscp -pw %password% .\*.sh %user%@%ipAddress%:.


set ipAddress=10.0.1.4
echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"

set ipAddress=10.0.1.5
echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"


