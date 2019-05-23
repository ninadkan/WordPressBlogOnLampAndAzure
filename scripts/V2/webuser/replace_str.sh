#!/bin/bash
original_str='<Directory /var/www/>'
replace_str='<Directory /var/www/html/wordpress>'
sudo sed -i "s~$original_str~$replace_str~" /etc/apache2/apache2.conf
