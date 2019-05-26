#!/bin/bash
# This script should be copied to webuser, chmod + x 
# and then executed to check sudo permissions grant
echo '=========== default update and upgrade ======================='
sudo apt-get update 
sudo apt-get upgrade -y

#sudo apt-get install debconf-utils

echo '===========   mysqlinstallation        ======================='
sudo apt-get install -y mysql-server-5.7
mysql_secure_installation

echo '===========   mysqlinstallation        ======================='
sudo systemctl start mysql
sudo systemctl enable mysql


echo '===========   creating databasee       ======================='
mysql -u root -p < sqlCommands.sql

echo '===========  test local user access   ========================'

echo '===========  substituting local access   ====================='
sudo python py_file_replace_str.py /etc/mysql/mysql.conf.d/mysqld.cnf "127.0.0.1" "10.0.2.4"

echo '===========  restart mysql access   =========================='
sudo systemctl restart mysql

echo '===========  Allow right ports      =========================='
sudo ufw allow mysql

echo '===========  Check some answers      ========================='
sudo netstat -plunt | grep mysqld

echo '....done'



