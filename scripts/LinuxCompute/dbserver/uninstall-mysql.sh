echo 'uninstall and remove all MySQL packages'

sudo apt-get remove --purge mysql-server mysql-client mysql-common -y
sudo apt-get autoremove -y
sudo apt-get autoclean


echo 'Remove the MySQL folder'
sudo rm -rf /etc/mysql

echo '...done' 

