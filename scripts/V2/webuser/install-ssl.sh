#!/bin/bash

echo 'Important: Before executing this script you set the https from wordpress admin site'

echo 'installing and configuring the certificates on the machine............'
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot 
sudo apt-get update 
sudo apt-get install certbot
sudo certbot certonly --webroot -w /var/www/html/wordpress -d blogs.ninadkanthi.co.uk
sudo chown -R webuser:webuser /etc/letsencrypt/live
sudo chown -R webuser:webuser /var/log/apache2
sudo chown -R www-data:www-data /var/www/html
cat /etc/letsencrypt/live/blogs.ninadkanthi.co.uk/README

echo '.........................................certificate installation fine'
echo '...............  creating back-up copy og default-ssl.conf    -----------'
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/wordpress-ssl.conf

echo '...............  substituting values in wordpress-ssl.conf    -----------'
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "ServerAdmin webmaster@localhost"  "ServerAdmin webmaster@localhost \n\t\t\tServerName ninadkanthi.co.uk \n\t\t\tServerAlias www.ninadkanthi.co.uk"
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "DocumentRoot /var/www/html" "DocumentRoot /var/www/html/wordpress"
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "/etc/ssl/certs/ssl-cert-snakeoil.pem" "/etc/letsencrypt/live/blogs.ninadkanthi.co.uk/fullchain.pem"
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "/etc/ssl/private/ssl-cert-snakeoil.key" "/etc/letsencrypt/live/blogs.ninadkanthi.co.uk/privkey.pem"
echo '...............  substituting values in wordpress.conf    -----------'
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress.conf" "/etc/ssl/private/ssl-cert-snakeoil.key" "/etc/letsencrypt/live/blogs.ninadkanthi.co.uk/privkey.pem"
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress.conf" "#Include conf-available/serve-cgi-bin.conf" "#Include conf-available/serve-cgi-bin.conf \n\t\t\tRedirect / https://blogs.ninadkanthi.co.uk/"

echo ' -------------------test that everything is ok ; if error, next step will not work ----'
sudo apachectl configtest

echo ' -------------------switching SSL on --------------------------------------------------'
sudo a2enmod ssl
sudo a2ensite wordpress-ssl.conf
sudo service apache2 restart
sudo service apache2 reload

echo "..............Done"



