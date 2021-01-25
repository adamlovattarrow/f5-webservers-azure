#!/bin/bash

apt-get update
apt-get install php phpldapadmin libapache2-mod-php tzdata apache2 vim curl -y
rm -rf /etc/apache2
rm -rf /var/www
curl -JLO 'https://arrowtfassets.blob.core.windows.net/assets/f5test.tar'
tar -xvf f5test.tar
mv etc/apache2 /etc/apache2
mv var/www /var/www
chmod -R 755 /var/www/
systemctl restart apache2
