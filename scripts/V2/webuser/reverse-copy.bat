set password=<<password without quotes>>
set user=webuser
set ipAddress=10.0.1.4

echo %password%
echo %user%@%ipAddress%

pscp -pw %password% %user%@%ipAddress%:./*.sh .
pscp -pw %password% %user%@%ipAddress%:./*.py .

