set password=<<password with quotes>>
set user=webuser
set ipAddress=10.0.2.4

echo %password%
echo %user%@%ipAddress%

pscp -pw %password% %user%@%ipAddress%:./*.sh .
pscp -pw %password% %user%@%ipAddress%:./*.py .
pscp -pw %password% %user%@%ipAddress%:./*.sql .

