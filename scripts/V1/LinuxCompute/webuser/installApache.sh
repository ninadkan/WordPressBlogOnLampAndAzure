#!/bin/bash
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot 
sudo apt-get update 
sudo apt-get install certbot
sudo certbot certonly --webroot -w /var/www/html/wordpress -d blogs.ninadkanthi.co.uk
sudo chown -R webuser:webuser /etc/letsencrypt/live
cat /etc/letsencrypt/live/blogs.ninadkanthi.co.uk/README