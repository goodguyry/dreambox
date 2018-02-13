#!/bin/bash
#
# Post-install Apache setup.
#

echo "Finishing Apache setup"

TEMPLATE_PATH='/usr/local/dh/apache2/template';
INSTANCE_NAME='apache2-dreambox';
INSTANCE_PATH="${TEMPLATE_PATH/%template/$INSTANCE_NAME}";

# Create necessary directories
declare -a DIRS=(
  "${TEMPLATE_PATH}"/etc/vhosts
  "${TEMPLATE_PATH}"/etc/ssl.crt
  /var/log/apache2/dreambox
)

for INDEX in ${!DIRS[*]}; do
  [[ ! -d "${DIRS[$INDEX]}" ]] && mkdir -p "${DIRS[$INDEX]}";
done

# Move the ports file into place
# @todo put this in the deb package
cp /usr/local/dreambox/ports.conf "${TEMPLATE_PATH}"/etc/vhosts/

# Change httpd2 init script to use /bin/bash
# There are error when running in Bash
sed -i -r 's/(#! )(\/bin\/sh)/\1 \/bin\/bash/' /etc/init.d/httpd2;

# Load mod_fcgid
# @todo maybe just move this to the repo with the changes set
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
# @include this in the file and change the path all at once above
sed -i -r '/ServerRoot \"\/usr\/local\/dh\/apache2\'/"/a PidFile '/var/run/${INSTANCE_NAME}-httpd.pid'" \
  "${INSTANCE_PATH}"/etc/httpd.conf;

# Set Apache to start at boot
sysv-rc-conf apache2 on
sysv-rc-conf --list apache2

# Start Apache
/etc/init.d/httpd2 start;
