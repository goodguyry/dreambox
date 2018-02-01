#!/bin/bash
#
# Post-install Apache setup.
#

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

echo "Starting Apache"
/etc/init.d/apache2 start
# /etc/init.d/apache2: line 15: /usr/local/apache2/bin/apachectl: No such file or directory
