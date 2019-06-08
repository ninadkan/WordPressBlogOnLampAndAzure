#!/bin/bash
echo '...............  Starting SSL Deployment    ..........................................'
#echo 'Important: Before executing this script you set the https from wordpress admin site'
echo '...............  Assigning Permissions    ............................................'

sudo chown -R webuser:webuser /etc/apache2/
sudo chown -R www-data:www-data /etc/apache2/
sudo chown -R webuser:webuser /var/www/html
sudo chown -R www-data:www-data /var/www/html
sudo chown -R webuser:webuser /var/log/apache2

echo '...............  creating back-up copy of default-ssl.conf    .........................'
sudo cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/wordpress-ssl.conf

echo ' ..............  installing and configuring the certificates on the machine............'
# if installing from letscertify, uncomment the following section
# ================  Lets encrypt SSL                  ========================
echo ' .........   certificate installation from letscertify ..................'
if [ -d "/etc/letsencrypt" ];
then
    echo "......... Assuming that LetsCertify certificates would be remotely installed. ......... "
    sudo chown -R webuser:webuser /etc/letsencrypt/
    sudo chown -R www-data:www-data /etc/letsencrypt/
else
    echo "......... Installing LetsCertify certificates      .................................... "
    sudo apt-get install -y software-properties-common
    sudo add-apt-repository ppa:certbot/certbot 
    sudo apt-get update 
    sudo apt-get install -y certbot
    # uncomment one of the followinc commands
    #sudo certbot certonly --dry-run --webroot -w /var/www/html/wordpress -d blogs.ninadkanthi.co.uk
    sudo certbot certonly --webroot -w /var/www/html/wordpress -d blogs.ninadkanthi.co.uk
    sudo chown -R webuser:webuser /etc/letsencrypt/
    sudo chown -R www-data:www-data /etc/letsencrypt/
fi 

echo '...................            If everything ok, then next line should be ok ...............'
cat /etc/letsencrypt/live/blogs.ninadkanthi.co.uk/README
# assuming evrything is going ok

echo '...............  substituting values in wordpress-ssl.conf    ..............................'
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "/etc/ssl/certs/ssl-cert-snakeoil.pem" "/etc/letsencrypt/live/blogs.ninadkanthi.co.uk/fullchain.pem"
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "/etc/ssl/private/ssl-cert-snakeoil.key" "/etc/letsencrypt/live/blogs.ninadkanthi.co.uk/privkey.pem"    


 echo '.........DONE certificate installation fine from letscertify ..............................'
# ================  Lets encrypt SSL                  ========================

# If installing from pre-configured SSL files uncomment following lines
# ================  Pre-configured SSL                  ========================
#echo '       configuring SSL for pre-created SSL files    -----------'

#sudo apt-get update 
#sudo mkdir /etc/ninadkanthi.co.uk
#sudo chown -R webuser:webuser /etc/ninadkanthi.co.uk
#sudo chown -R www-data:www-data /etc/ninadkanthi.co.uk
#sudo cp *.crt /etc/ninadkanthi.co.uk
#sudo cp *.key /etc/ninadkanthi.co.uk 
#sudo cp *.csr /etc/ninadkanthi.co.uk

#sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "/etc/ssl/certs/ssl-cert-snakeoil.pem" "/etc/ninadkanthi.co.uk/8e61c57d613db53b.crt"
#sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "/etc/ssl/private/ssl-cert-snakeoil.key" "/etc/ninadkanthi.co.uk/ninadkanthi.co.uk.key"
#sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "#SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt" "SSLCertificateChainFile /etc/ninadkanthi.co.uk/gd_bundle-g2-g1.crt"
# ================  Pre-configured SSL                  ========================


echo '...............  substituting values in wordpress-ssl.conf    ..................................'
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "ServerAdmin webmaster@localhost"  "ServerAdmin webmaster@localhost \n\t\t\tServerName ninadkanthi.co.uk \n\t\t\tServerAlias www.ninadkanthi.co.uk"
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress-ssl.conf" "DocumentRoot /var/www/html" "DocumentRoot /var/www/html/wordpress"
echo ' -------------- [DONE] configuring SSL for pre-created SSL files'

echo '...............  substituting values in wordpress.conf    ......................................'
#sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress.conf" "/etc/ssl/private/ssl-cert-snakeoil.key" "/etc/ninadkanthi.co.uk/ninadkanthi.co.uk.key"
sudo python py_file_replace_str.py "/etc/apache2/sites-available/wordpress.conf" "#Include conf-available/serve-cgi-bin.conf" "#Include conf-available/serve-cgi-bin.conf \n\t\t\tRedirect / https://blogs.ninadkanthi.co.uk/"

echo ' ...................test that everything is ok ; if error, next step will not work .............'
sudo apachectl configtest

echo ' .................. switching SSL on ...........................................................'
sudo a2enmod ssl
sudo a2ensite wordpress-ssl.conf
sudo service apache2 restart
sudo service apache2 reload

echo "..............Done ............................................................................"



