set password=<<PASSWORD_HERE>>
set user=webuser
set ipAddress=10.0.1.4

echo %user%@%ipAddress%

pscp -pw %password% .\*.sh %user%@%ipAddress%:.
pscp -pw %password% .\*.py %user%@%ipAddress%:.
pscp -pw %password% .\*.csr %user%@%ipAddress%:.
pscp -pw %password% .\*.key %user%@%ipAddress%:.
pscp -pw %password% .\*.crt %user%@%ipAddress%:.

rem pscp -pw %password% .\ninadkanthi.co.uk\*.* %user%@%ipAddress%:.


echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"
rem echo './install.sh'
rem ssh %user%@%ipAddress% "./install.sh"

set ipAddress=10.0.1.5
pscp -pw %password% .\*.sh %user%@%ipAddress%:.
pscp -pw %password% .\*.py %user%@%ipAddress%:.
pscp -pw %password% .\*.csr %user%@%ipAddress%:.
pscp -pw %password% .\*.key %user%@%ipAddress%:.
pscp -pw %password% .\*.crt %user%@%ipAddress%:.

rem pscp -pw %password% .\ninadkanthi.co.uk\*.* %user%@%ipAddress%:.

echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"
rem echo './install.sh'
rem ssh %user%@%ipAddress% "./install.sh"
