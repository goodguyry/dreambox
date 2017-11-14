#!/bin/bash

##
# Apache
##

echo 'Finishing Apache install'

# Set Apache to start at boot
cp /tmp/files/http/apache2 /etc/init.d/ && chmod +x /etc/init.d/apache2
ln -s /usr/lib/insserv/insserv /sbin/insserv
sysv-rc-conf apache2 on
sysv-rc-conf --list apache2

# Set permissions for htdocs
chown -R www-data:www-data /usr/local/apache2/htdocs

# Set Apache logs
# Remove any existing log directories
# Create the logs directories
declare -a DIRECTORIES=(
  /usr/local/apache2/logs
  /usr/local/apache2/logs/dreambox
)

for DIRECTORY in ${DIRECTORIES[*]}; do
  if [[ -d ${DIRECTORY} ]]; then
    rm -r ${DIRECTORY}
  fi
  mkdir ${DIRECTORY}
done




##
# MySQL
##

# Postinstallation setup
# https://dev.mysql.com/doc/refman/5.5/en/installing-source-distribution.html

echo "Finishing MySQL install"

# Create user and group
groupadd mysql
useradd -g mysql mysql

cd /usr/local/mysql 2>&1

# Update permissions
chown -R mysql . 2>&1
chgrp -R mysql . 2>&1

# Create GRANT tables
scripts/mysql_install_db --user=mysql >/dev/null

# Update permissions
chown -R root . 2>&1
chown -R mysql data 2>&1

# Create the conf based on one of the pre-build confs
cp support-files/my-medium.cnf /etc/my.cnf

# Set MySQL to start at boot

cp support-files/mysql.server /etc/init.d/mysql.server
update-rc.d mysql.server defaults

cd - >/dev/null




echo "Starting Apache"
/etc/init.d/apache2 start

echo "Starting MySQL"
/etc/init.d/mysql.server start
