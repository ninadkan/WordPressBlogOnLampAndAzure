#!/bin/bash
# this  file should be copied to the root of remote user home folder
# chmod +x on this and then executed. 
# this will add a webuser which will be used to install all the local 
# software
sudo adduser --gecos "" webuser
sudo usermod -aG sudo webuser
#su - webuser

