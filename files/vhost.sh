#!/bin/bash

#
# Set up the virtual host.
#

set -e;
set -u;

port_file='/usr/local/dh/apache2/apache2-dreambox/etc/vhosts/ports.conf';

# Set the new vhost conf file in place.
cp /usr/local/dreambox/ndn-vhost.conf "${vhost_file}";

# Create vhost log directory.
[[ ! -d /var/log/apache2/dreambox/"${host}" ]] && mkdir -p /var/log/apache2/dreambox/"${host}";

# Set Apache directory.
ESCAPED_ROOT_PATH=$(echo "${root_path}" | sed 's/\(\W\)/\\\1/g');
sed -i s/"%root_path%"/"${ESCAPED_ROOT_PATH}"/ "${vhost_file}";

# Update hostname throughout.
sed -i -r s/"%host%"/"${host}/" "${vhost_file}";

# Update vhost file for SSL.
if [[ 'true' == $ssl ]]; then
  # Enable the NameVirtualHost on port 443.
  sed -i -r 's/(#\s)(NameVirtualHost\s\*:443)/\2/' "${port_file}";
  # Listen 443.
  sed -i -r 's/(#\s)(Listen\s)(80)/\2443/' "${vhost_file}";
  # <VirtualHost *:443>.
  sed -i -r 's/\*:80/\*:443/g' "${vhost_file}";
  # SSLEngine on.
  sed -i -r 's/(SSLEngine\s)\w*/\1on/' "${vhost_file}";
  # SSLCertificateFile & SSLCertificateKeyFile.
  sed -i -r s/'(#\s)(SSLCertificate.*)(%cert_name%)'/"\2${box_name}"/ "${vhost_file}";
else
  # Enable the NameVirtualHost on port 80.
  sed -i -r 's/(#\s)(NameVirtualHost\s\*:80)/\2/' "${port_file}";
fi

# Create root path.
# For when the site's public directory isn't the site root.
[[ ! -d "${root_path}" ]] && mkdir -p "${root_path}";

# Update permissions.
chown -R "${user}:${group}" "/home/${user}";

# Restart Apache.
/etc/init.d/httpd2 restart;

exit $?;
