filename = '/etc/apache2/sites-available/wordpress.conf'
originalstr='<VirtualHost *:80>'
finalstr='<VirtualHost *:80> \n\t ServerName ninadkanthi.co.uk \n\t ServerAlias www.ninadkanthi.co.uk'

nextString='DocumentRoot /var/www/html'
nextReplacementString='DocumentRoot /var/www/html/wordpress \n\t <Directory /var/www/html/wordpress> \n\t\t Require all granted \n\t </Directory>'


with open(filename, 'r') as file:
	filedata = file.read()

filedata = filedata.replace(originalstr,finalstr)
filedata = filedata.replace(nextString, nextReplacementString)

with open(filename, 'w') as file:
	file.write(filedata)



