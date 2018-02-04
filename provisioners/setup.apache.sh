#!/bin/bash
#
# Post-install Apache setup.
#

echo "Finishing Apache setup"

TEMPLATE_PATH='/usr/local/dh/apache2/template';
INSTANCE_NAME='apache2-dreambox';
INSTANCE_PATH="${TEMPLATE_PATH/%template/$INSTANCE_NAME}";

# Create necessary directories
[[ ! -d "${TEMPLATE_PATH}"/etc/vhosts ]] && mkdir "${TEMPLATE_PATH}"/etc/vhosts
[[ ! -d "${TEMPLATE_PATH}"/etc/ssl.crt ]] && mkdir "${TEMPLATE_PATH}"/etc/ssl.crt
[[ ! -d /var/log/apache2/dreambox ]] && mkdir -p /var/log/apache2/dreambox

# Move the ports file into place
cp /tmp/files/http/ports.conf "${TEMPLATE_PATH}"/etc/vhosts/

# Change httpd2 init script to use /bin/bash
# There are error when running in Bash
sed -i -r 's/(#! )(\/bin\/sh)/\1 \/bin\/bash/' /etc/init.d/httpd2;

# Load mod_fcgid
sed -i -r '/LoadModule rewrite_module.*\.so/a LoadModule fcgid_module lib/modules/mod_fcgid.so' \
  "${TEMPLATE_PATH}"/etc/httpd.conf;
# Include the VHost directory
sed -i -r 's/(#)(Include etc\/)extra\/httpd-vhosts\.conf/\2vhosts\/\*/' \
  "${TEMPLATE_PATH}"/etc/httpd.conf;

# Duplicate template as new instance
cp -r "${TEMPLATE_PATH}" "${INSTANCE_PATH}";
# Link httpd file to instance root
ln -s "${INSTANCE_PATH}"/sbin/httpd "${INSTANCE_PATH}"/"${INSTANCE_NAME}"-httpd;
# Change the config paths
sed -i -r s'/(\/usr\/local\/dh\/apache2\/)(template)'/"\1${INSTANCE_NAME}/" \
  "${INSTANCE_PATH}"/etc/httpd.conf;
# Set the PID path
sed -i -r '/ServerRoot \"\/usr\/local\/dh\/apache2\'/"/a PidFile '/var/run/${INSTANCE_NAME}-httpd.pid'" \
  "${INSTANCE_PATH}"/etc/httpd.conf;

# Set Apache to start at boot
sysv-rc-conf apache2 on
sysv-rc-conf --list apache2

# Start Apache
/etc/init.d/httpd2 start;
