#!/bin/bash
sudo apt-get install apache2
sudo systemctl start apache2
sudo systemctl enable apache2
# check status
#sudo systemctl status apache2
