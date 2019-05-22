set password=<<password with quotes>>
set user=ninadk
set ipAddress=10.0.2.4

echo %password%
echo %user%@%ipAddress%

pscp -pw %password% .\*.sh %user%@%ipAddress%:.
pscp -pw %password% .\*.py %user%@%ipAddress%:.
pscp -pw %password% .\*.sql %user%@%ipAddress%:.

