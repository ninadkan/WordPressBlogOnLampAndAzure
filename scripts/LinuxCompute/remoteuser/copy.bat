set password=<<password without quotes>>
set user=ninadk
set ipAddress=10.0.1.5

echo %password%
echo %user%@%ipAddress%

pscp -pw %password% .\*.sh %user%@%ipAddress%:.

set ipAddress=10.0.1.4
pscp -pw %password% .\*.sh %user%@%ipAddress%:.

set ipAddress=10.0.2.4
pscp -pw %password% .\*.sh %user%@%ipAddress%:.