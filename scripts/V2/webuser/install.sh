#!/bin/bash
# This script should be copied to webuser, chmod + x 
# and then executed to check sudo permissions grant

echo '************************************************************************'
echo '************************************************************************'
echo '************************************************************************'
echo ' ensure that you have substituted value of password_here before ececuting'

sudo apt-get update
sudo apt-get upgrade

echo 'installing apache2.............'

sudo apt install apache2

echo 'restarting, enavbling apache 2' 
sudo systemctl start apache2
sudo systemctl enable apache2

apache2 -version

echo 'installing php................'

sudo apt-get install php7.0 libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-mbstring php7.0-gd php7.0-xml php7.0-xmlrpc php7.0-intl php7.0-soap php7.0-zip
echo 'restarting apache2'

sudo systemctl restart apache2

hostname -I

echo 'downloading wordpress.........'

sudo wget -c http://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz

echo 'updating wp-config file .....'

eval homedir=~
echo $homedir
wpfilepath=$homedir/wordpress/wp-config.php
echo 'copying wordpress files......'
sudo cp ~/wordpress/wp-config-sample.php $wpfilepath

echo 'substituting values ......'


sudo python py_file_replace_str.py $wpfilepath "database_name_here" "wordpress"
sudo python py_file_replace_str.py $wpfilepath "username_here" "remotewpuser"
sudo python py_file_replace_str.py $wpfilepath "password_here" "<<substitute here>>"
sudo python py_file_replace_str.py $wpfilepath "localhost" "10.0.2.4"

echo 'changing owner on folders...'
sudo chown -R www-data:www-data /var/www/html
sudo chown -R webuser:webuser /var/www/html

echo 'creating wordpress folder...'
sudo mkdir /var/www/html/wordpress

echo 'copying all wordpress files.'
sudo cp -a ~/wordpress/* /var/www/html/wordpress

echo 'restarting apache2'
sudo systemctl restart apache2
sudo systemctl reload apache2

echo "replacing default location to wordpress"
source ./replace_str.sh
sudo systemctl restart apache2

echo "replacing 000-default.conf with wordpress.conf "
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
sudo python py_file_sub_str.py


echo "enabling wordpress.conf as the web site default"
sudo a2dissite 000-default.conf
sudo a2ensite wordpress.conf
sudo service apache2 restart
sudo service apache2 reload

echo '....done'



