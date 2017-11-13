#!/bin/bash

port_file=/usr/local/apache2/conf/vhosts/ports.conf

# Set the new vhost conf file in place
cp /usr/local/dreambox/httpd-vhosts.conf "${vhost_file}"

# Set Apache directory
ESCAPED_SITE_ROOT=$(echo "${root_path}" | sed 's/\(\W\)/\\\1/g');
sed -i s/"\/usr\/local\/apache2\/htdocs"/"${ESCAPED_SITE_ROOT}"/ "${vhost_file}";

# ServerName
sed -i -r s/"(ServerName\s)\w*\.\w*"/"\1${host}/" "${vhost_file}"

# Update vhost file for SSL
if [[ 'true' == $ssl ]]; then
  # Enable the NameVirtualHost on port 443
  sed -i -r 's/(#\s)(NameVirtualHost\s\*:443)/\2/' "${port_file}"
  # Listen 443
  sed -i -r 's/(#\s)(Listen\s)(80)/\2443/' "${vhost_file}"
  # <VirtualHost *:443>
  sed -i -r 's/\*:80/\*:443/g' "${vhost_file}"
  # SSLEngine on
  sed -i -r 's/(SSLEngine\s)\w*/\1on/' "${vhost_file}"
  # SSLCertificateFile
  sed -i -r s/'(#\s)(SSLCertificateFile\s)(\/usr\/local\/apache2\/conf\/)\w*\.crt'/"\2\3${box_name}\.crt"/ "${vhost_file}"
  # SSLCertificateKeyFile
  sed -i -r s/'(#\s)(SSLCertificateKeyFile\s)(\/usr\/local\/apache2\/conf\/)\w*\.key'/"\2\3${box_name}\.key"/ "${vhost_file}"
else
  # Enable the NameVirtualHost on port 80
  sed -i -r 's/(#\s)(NameVirtualHost\s\*:80)/\2/' "${port_file}"
fi

# Create root path
# For when the site's public directory isn't the site root
if [[ ! -d "${root_path}" ]]; then
  mkdir -p "${root_path}"
fi

# Change ownership to Dreambox user
echo "chown -R ${user}:${group} /home/${user}"
chown -R "${user}:${group}" "/home/${user}"

# Restart Apache
/etc/init.d/apache2 restart  >/dev/null

echo

[[ $? -lt 1 ]] && echo -e "User setup complete.\n"
