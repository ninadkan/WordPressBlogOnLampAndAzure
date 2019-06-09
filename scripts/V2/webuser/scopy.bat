
rem @echo OFF

echo "remove any existing remanants of lets encrypt folder"
del letsencrypt 
set userName=webuser
set ipAddress=52.151.106.28

echo %userName%@%ipAddress%
echo "copy default files to 1"
scp .\* %userName%@%ipAddress%:.

rem Now install the basic WordPress
ssh %userName%@%ipAddress% "chmod +x ./*.sh"
ssh %userName%@%ipAddress% "./install.sh"

rem Now install the basic SSL - assuming its LetsEncrypt
ssh %userName%@%ipAddress% "./install-ssl.sh"

rem Now copy all the letsEncrypt files back locally
ssh %userName%@%ipAddress% "sudo chown -R webuser:webuser /etc/letsencrypt/"
scp -r %userName%@%ipAddress%:/etc/letsencrypt/ .

rem Now copy all the files back
set ipAddress2=52.151.106.32
echo %userName%@%ipAddress2%

rem copy default files to 2
scp .\* %userName%@%ipAddress2%:.

rem make necessary folder structure
ssh %userName%@%ipAddress2% "sudo mkdir /etc/letsencrypt"
ssh %userName%@%ipAddress2% "sudo mkdir /etc/letsencrypt/live"
ssh %userName%@%ipAddress2% "sudo mkdir /etc/letsencrypt/live/blogs.ninadkanthi.co.uk"

rem change ownerships 
ssh %userName%@%ipAddress2% "sudo chown -R webuser:webuser /etc/letsencrypt/"

rem Copy lets encrypt files to secondary machine
scp -r .\letsencrypt\live\blogs.ninadkanthi.co.uk %userName%@%ipAddress2%:/etc/letsencrypt/live
@echo off
rem Not able to do it with one command here as erros as Host key certification failed. 
rem scp -r %userName%@%ipAddress%:/etc/letsencrypt/ %userName%@%ipAddress2%:/etc/letsencrypt/scopy.

@echo on

rem default installation on secondary machine now. 
ssh %userName%@%ipAddress2% "chmod +x ./*.sh"
ssh %userName%@%ipAddress2% "./install.sh"
ssh %userName%@%ipAddress2% "./install-ssl.sh"

