#!/bin/bash

##
# Apache
##

echo 'Finishing Apache install'

# Set Apache to start at boot
# @review: compare to dh apache2 init.d file
cp /tmp/files/http/apache2 /etc/init.d/ && chmod +x /etc/init.d/apache2
# @review: failed to create symbolic link ‘/sbin/insserv’
ln -s /usr/lib/insserv/insserv /sbin/insserv
sysv-rc-conf apache2 on
sysv-rc-conf --list apache2

# Set permissions for htdocs
# @review: cannot access ‘/usr/local/apache2/htdocs’
# @todo: should be '/usr/local/dh/apache2/template/htdocs'
chown -R www-data:www-data /usr/local/apache2/htdocs

# Set Apache logs
# Remove any existing log directories
# Create the logs directories
declare -a DIRECTORIES=(
  /usr/local/apache2/logs
  /usr/local/apache2/logs/dreambox
)

# @review: cannot create directory ‘/usr/local/apache2/logs’
# @review: cannot create directory ‘/usr/local/apache2/logs/dreambox’
# @todo: should be '/usr/local/dh/apache2/template/logs'
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

# @review: /tmp/vagrant-shell: line 49: cd: /usr/local/mysql: No such file or directory
# @todo: should this be /etc/mysql/ ?
cd /usr/local/mysql 2>&1

# Update permissions
chown -R mysql . 2>&1
chgrp -R mysql . 2>&1

# Create GRANT tables
# @review: /tmp/vagrant-shell: line 56: scripts/mysql_install_db: No such file or directory
scripts/mysql_install_db --user=mysql >/dev/null

# Update permissions
chown -R root . 2>&1
chown -R mysql data 2>&1

# Create the conf based on one of the pre-build confs
# @review: cannot stat ‘support-files/my-medium.cnf’
# @review: there's a /etc/mysql/my.cnf...
cp support-files/my-medium.cnf /etc/my.cnf

# Set MySQL to start at boot

# @review: cannot stat ‘support-files/mysql.server’
cp support-files/mysql.server /etc/init.d/mysql.server
# @review: update-rc.d: /etc/init.d/mysql.server: file does not exist
update-rc.d mysql.server defaults

# @review: /tmp/vagrant-shell: line 77: cd: OLDPWD not set
cd - >/dev/null



echo "Starting Apache"
/etc/init.d/apache2 start
# /etc/init.d/apache2: line 15: /usr/local/apache2/bin/apachectl: No such file or directory

echo "Starting MySQL"
/etc/init.d/mysql.server start
# /tmp/vagrant-shell: line 86: /etc/init.d/mysql.server: No such file or directory
