#!/bin/bash

#
# Post-install MySQL setup.
# https://dev.mysql.com/doc/refman/5.5/en/installing-source-distribution.html
#

set -e;

echo 'Finishing MySQL install';

# Create the mysql group.
if grep -q mysql /etc/group; then
  echo 'Group mysql already exists';
else
  groupadd mysql;
fi;

# Create the mysql user.
if $(getent passwd mysql >/dev/null); then
  echo 'User mysql already exists.';
else
  useradd -g mysql mysql;
fi;

# Update permissions.
chgrp -R mysql /etc/mysql;
chown -R mysql /var/lib/mysql;

# Run `mysql_secure_installation` script.
SECURE_MYSQL=$(expect -c "
set timeout 10
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"root\r\"
expect \"Change the root password?\"
send \"n\r\"
expect \"Remove anonymous users?\"
send \"y\r\"
expect \"Disallow root login remotely?\"
send \"y\r\"
expect \"Remove test database and access to it?\"
send \"y\r\"
expect \"Reload privilege tables now?\"
send \"y\r\"
expect eof
");

echo "${SECURE_MYSQL}";

# Set MySQL to start at boot.
sysv-rc-conf --level 345 mysql on;

# Restart MySQL.
/etc/init.d/mysql restart;

exit $?;
