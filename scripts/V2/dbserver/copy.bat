set password=<<InsertPasswordHere>>
set user=webuser
set ipAddress=10.0.2.4

echo %user%@%ipAddress%

pscp -pw %password% .\*.sh %user%@%ipAddress%:.
pscp -pw %password% .\*.py %user%@%ipAddress%:.
pscp -pw %password% .\*.sql %user%@%ipAddress%:.

echo 'chmod + x scripts'
ssh %user%@%ipAddress% "chmod +x ./*.sh"



