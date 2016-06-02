#!/bin/bash

##
# Apache
##

# Set Apache to start at boot
echo "Setting Apache to start at boot"
cp /tmp/files/http/apache2 /etc/init.d/
chmod +x /etc/init.d/apache2
ln -s /usr/lib/insserv/insserv /sbin/insserv
chkconfig --add apache2 > /dev/null 2>&1
chkconfig --list apache2

# Set permissions for htdocs
echo "Setting permissions for htdocs"
chown -R www-data:www-data /usr/local/apache2/htdocs

# Set Apache logs
echo "Setting Apache logs"
# Remove any existing log directories
declare -a DIRECTORIES=(
  /usr/local/apache2/logs
  /usr/local/apache2/logs/dreambox
)

# Create the logs directories
for DIRECTORY in ${DIRECTORIES[*]}; do
  if [[ -d ${DIRECTORY} ]]; then
    rm -r ${DIRECTORY}
  fi
  mkdir ${DIRECTORY}
done




##
# ModSecurity
##

# Download OWASP ModSecurity rules
echo "Downloading OWASP ModSecurity rules"
wget https://github.com/SpiderLabs/owasp-modsecurity-crs/tarball/master -O /usr/local/apache2/master.tar.gz > /dev/null 2>&1

# Unpack the files
echo "Unpacking the files"
tar xvf /usr/local/apache2/master.tar.gz -C /usr/local/apache2/ > /dev/null 2>&1

# Rename the directory
mv /usr/local/apache2/SpiderLabs-owasp-modsecurity-crs-* /usr/local/apache2/modsecurity-crs
rm /usr/local/apache2/master.tar.gz

echo "Setting modsecurity rules"

# Set the configuration files
cp /usr/local/src/modsecurity.conf-recommended /usr/local/apache2/modsecurity-crs/modsecurity.conf

cp /usr/local/src/unicode.mapping /usr/local/apache2/modsecurity-crs/

mv /usr/local/apache2/modsecurity-crs/modsecurity_crs_10_setup.conf.example /usr/local/apache2/modsecurity-crs/modsecurity_crs_10_setup.conf

# Link rules for httpd.conf to find
ln -s /usr/local/apache2/modsecurity-crs/modsecurity_crs_10_setup.conf /usr/local/apache2/modsecurity-crs/activated_rules/modsecurity_crs_10_setup.conf

for f in `ls /usr/local/apache2/modsecurity-crs/base_rules/`; do
  ln -s /usr/local/apache2/modsecurity-crs/base_rules/$f /usr/local/apache2/modsecurity-crs/activated_rules/$f
done

for f in `ls /usr/local/apache2/modsecurity-crs/optional_rules/ | grep comment_spam`; do
  ln -s /usr/local/apache2/modsecurity-crs/optional_rules/$f /usr/local/apache2/modsecurity-crs/activated_rules/$f
done

# Activate mod_security
sed -i 's/\(SecRuleEngine\) DetectionOnly/\1 On/' /usr/local/apache2/modsecurity-crs/modsecurity.conf




##
# MySQL
##

# Postinstallation setup
# https://dev.mysql.com/doc/refman/5.5/en/installing-source-distribution.html

# Create user and group
echo "Creating user and group"
groupadd mysql
useradd -g mysql mysql

cd /usr/local/mysql 2>&1

# Set permissions
chown -R mysql . 2>&1
chgrp -R mysql . 2>&1

# Create GRANT tables
echo "Creating GRANT tables"
scripts/mysql_install_db --user=mysql >/dev/null

# Reset persmissions
chown -R root . 2>&1
chown -R mysql data 2>&1

# Create the conf based in one of the pre-build confs
cp support-files/my-medium.cnf /etc/my.cnf

# Set mysql to start at boot
echo "Setting mysql to start at boot"
cp support-files/mysql.server /etc/init.d/mysql.server
update-rc.d mysql.server defaults

cd - >/dev/null




# Start Apache
echo "Starting Apache"
/etc/init.d/apache2 start

# Start mysql
echo "Starting MySQL"
/etc/init.d/mysql.server start
