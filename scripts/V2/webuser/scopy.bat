set user=webuser
set ipAddress=51.145.125.67

echo %user%@%ipAddress%
scp .\*.* %user%@%ipAddress%:.

echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"
ssh %user%@%ipAddress% "./install.sh"
ssh %user%@%ipAddress% "./install-ssl.sh"


set ipAddress2=51.145.125.184

echo %user%@%ipAddress2%
scp .\*.* %user%@%ipAddress2%:.

echo 'chmod + x scripts'
ssh %user%@%ipAddress2% "chmod +x ./*.sh"
ssh %user%@%ipAddress2% "./install.sh"
ssh %user%@%ipAddress2% "./install-ssl.sh"

