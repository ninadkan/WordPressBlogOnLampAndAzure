set password=<<InsertPasswordHere>>
set user=webuser
set ipAddress=10.0.1.4

echo %password%
echo %user%@%ipAddress%

pscp -pw %password% %user%@%ipAddress%:./*.sh .
pscp -pw %password% %user%@%ipAddress%:./*.py .
pscp -pw %password% %user%@%ipAddress%:./*.key .
pscp -pw %password% %user%@%ipAddress%:./*.csr .
pscp -pw %password% %user%@%ipAddress%:./*.crt .



