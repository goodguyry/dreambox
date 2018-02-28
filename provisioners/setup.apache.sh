#!/bin/bash

#
# Post-install Apache setup.
#

set -e;

echo 'Finishing Apache setup';

TEMPLATE_PATH='/usr/local/dh/apache2/template';
INSTANCE_NAME='apache2-dreambox';
INSTANCE_PATH="${TEMPLATE_PATH/%template/$INSTANCE_NAME}";

# Create necessary directories.
declare -a DIRS=(
  "${TEMPLATE_PATH}/etc/vhosts"
  "${TEMPLATE_PATH}/etc/ssl.crt"
  /var/log/apache2/dreambox
);

for INDEX in ${!DIRS[*]}; do
  [[ ! -d "${DIRS[$INDEX]}" ]] && mkdir -p "${DIRS[$INDEX]}";
done;

# Move the ports file into place.
rsync -av --exclude='ndn-vhost.conf' /usr/local/dreambox/*.conf "${TEMPLATE_PATH}/etc/";

# Change httpd2 init script to use /bin/bash.
# There are error when running in Bash.
sed -i -r 's/(#! )(\/bin\/sh)/\1 \/bin\/bash/' /etc/init.d/httpd2;

# Set up the Apache instance.

# Duplicate the template as new instance.
cp -r "${TEMPLATE_PATH}" "${INSTANCE_PATH}";
# Link the httpd file to instance root.
ln -s "${INSTANCE_PATH}/sbin/httpd" "${INSTANCE_PATH}"/"${INSTANCE_NAME}-httpd";
# Change the httpd.conf paths.
sed -i -r "s/(\/usr\/local\/dh\/apache2\/)(template)/\1${INSTANCE_NAME}/" \
  "${INSTANCE_PATH}/etc/httpd.conf";
# Set the PID path.
sed -i -r "s/(PidFile \"\/var\/run\/)(template)(-httpd\.pid\")/\1${INSTANCE_NAME}\3/" \
  "${INSTANCE_PATH}/etc/httpd.conf";

# Set Apache to start at boot.
sysv-rc-conf apache2 on;
sysv-rc-conf --list apache2;

# Start Apache.
/etc/init.d/httpd2 start;

exit $?;
