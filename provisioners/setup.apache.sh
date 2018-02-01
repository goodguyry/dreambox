#!/bin/bash
#
# Post-install Apache setup.
#

echo "Finishing Apache setup"

TEMPLATE_PATH='/dh/apache2/template';
INSTANCE_NAME='apache2-dreambox';
INSTANCE_PATH="${TEMPLATE_PATH/%template/$INSTANCE_NAME}";

# Create VHosts directory
[[ ! -d "${TEMPLATE_PATH}"/etc/extra/vhosts ]] && mkdir "${TEMPLATE_PATH}"/etc/extra/vhosts
cp /tmp/files/http/ports.conf "${TEMPLATE_PATH}"/etc/extra/vhosts/

# Change httpd2 init script to use /bin/bash
# There are error when running in Bash
sed -i -r 's/(#! )(\/bin\/sh)/\1 \/bin\/bash/' /etc/init.d/httpd2;

# Load mod_fcgid
sed -i -r '/LoadModule rewrite_module.*\.so/a LoadModule fcgid_module lib/modules/mod_fcgid.so' \
  "${TEMPLATE_PATH}"/etc/httpd.conf;
# Include the VHost directory
sed -i -r 's/(#)(Include etc\/extra\/)httpd-vhosts\.conf/\2vhosts\/\*/' \
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

# Create the logs directory
# @todo This could likely change to whatever... it just needs to match what's in ndn-vhost.conf
mkdir -p /home/_domain_logs/vagrant/dreambox.http/http.dreambox-instance;
# Copy the test vhost.conf into place
# @todo Once this is finalized, move to template with placeholder strings
cp /vagrant/files/http/ndn-vhost.conf "${INSTANCE_PATH}"/etc/extra/vhosts/;
# Create test domain path
# @todo Remove after testing
mkdir -p /home/vagrant/dreambox.http;
# Add a PHP info test page
# @todo Remove after testing
bash -c "echo '<?php phpinfo(); ?>' >> /home/vagrant/dreambox.http/index.php";

# Set Apache to start at boot
# @review: failed to create symbolic link ‘/sbin/insserv’
ln -s /usr/lib/insserv/insserv /sbin/insserv
sysv-rc-conf apache2 on
sysv-rc-conf --list apache2

# Set Apache logs
# Remove any existing log directories
# Create the logs directories
# @todo Find a better place for these
declare -a DIRECTORIES=(
  /var/log/apache2
  /var/log/apache2/dreambox
)

for DIRECTORY in ${DIRECTORIES[*]}; do
  if [[ -d ${DIRECTORY} ]]; then
    rm -r ${DIRECTORY}
  fi
  mkdir ${DIRECTORY}
done

# Start Apache
/etc/init.d/httpd2 start;
