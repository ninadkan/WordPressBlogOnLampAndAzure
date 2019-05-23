set password=<<password without quotes>>
set user=webuser
set ipAddress=10.0.1.5

echo %password%
echo %user%@%ipAddress%

pscp -pw %password% .\*.sh %user%@%ipAddress%:.
pscp -pw %password% .\*.py %user%@%ipAddress%:.

set ipAddress=10.0.1.4
pscp -pw %password% .\*.sh %user%@%ipAddress%:.
pscp -pw %password% .\*.py %user%@%ipAddress%:.
