#!/bin/bash

#
# Set up the virtual host.
#

set -e;
set -u;

port_file='/usr/local/dh/apache2/apache2-dreambox/etc/ports.conf';
hosts_line="${host}";

# Set the new vhost conf file in place.
cp /usr/local/dreambox/ndn-vhost.conf "${vhost_file}";

# Create vhost log directory.
[[ ! -d /var/log/apache2/dreambox/"${host}" ]] && mkdir -p /var/log/apache2/dreambox/"${host}";

# Set Apache directory.
ESCAPED_DOCUMENT_ROOT=$(echo "${document_root}" | sed 's/\(\W\)/\\\1/g');
sed -i "s/%document_root%/${ESCAPED_DOCUMENT_ROOT}/g" "${vhost_file}";

# Update hostname throughout.
sed -i -r "s/%host%/${host}/g" "${vhost_file}";

# Add alias(es)
if [[ ! -z ${aliases+x} ]]; then
  sed -i -r "s/(#\s)(ServerAlias)/\2 ${aliases}/" "${vhost_file}";
  hosts_line="${hosts_line} ${aliases}";
fi;

# Add the domains to /etc/hosts
echo "127.0.0.1 ${hosts_line}" >> /etc/hosts;

# Set the CGI script based on the PHP version
sed -i -r "s/%php_dir%/${php_dir}/g" "${vhost_file}";

# Update vhost file for SSL.
if [[ 'true' == $ssl ]]; then
  # Listen and NameVirtualHost on port 443.
  sed -i -r 's/(#\s)(.*443)/\2/' "${port_file}";
  # <VirtualHost *:443>.
  sed -i -r 's/\*:80/\*:443/g' "${vhost_file}";
  # SSLEngine on.
  sed -i -r 's/(SSLEngine\s)\w*/\1on/' "${vhost_file}";
  # SSLCertificateFile & SSLCertificateKeyFile.
  sed -i -r "s/(#\s)(SSLCertificate.*)/\2/" "${vhost_file}";
else
  # Listen and NameVirtualHost on port 80.
  sed -i -r 's/(#\s)(.*80)/\2/' "${port_file}";
fi;

# Create root path.
# For when the site's document root isn't the site root.
[[ ! -d "${document_root}" ]] && mkdir -p "${document_root}";

# Update permissions.
chown -R "${user}:${group}" "/home/${user}";

# Restart Apache.
/etc/init.d/httpd2 restart;

exit $?;
