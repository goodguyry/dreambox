#!/bin/bash

#
# Set up the phpmyadmin host.
#

set -e;
set -u;

document_root='/usr/local/dh/web';
host='dream.box';
hosts_line='dream.box';
php_dir='php56';
vhosts_dir='/usr/local/dh/apache2/apache2-dreambox/etc/vhosts/';

# Set the new vhost conf file in place.
cp /usr/local/dreambox/ndn-vhost.conf "/usr/local/dh/apache2/apache2-dreambox/etc/vhosts/phpmyadmin.conf";

# Create vhost log directory.
[[ ! -d /var/log/apache2/dreambox/dream.box ]] && mkdir -p /var/log/apache2/dreambox/dream.box;

# Set Apache directory.
ESCAPED_DOCUMENT_ROOT=$(echo "/usr/local/dh/web" | sed 's/\(\W\)/\\\1/g');
sed -i "s/%document_root%/\/usr\/local\/dh\/web/g" "/usr/local/dh/apache2/apache2-dreambox/etc/vhosts/phpmyadmin.conf";

# Update hostname throughout.
sed -i -r "s/%host%/dream.box/g" "/usr/local/dh/apache2/apache2-dreambox/etc/vhosts/phpmyadmin.conf";

# Add the domains to /etc/hosts
echo "127.0.0.1 dream.box" >> /etc/hosts;

# Set the CGI script based on the PHP version
sed -i -r "s/%php_dir%/php56/g" "/usr/local/dh/apache2/apache2-dreambox/etc/vhosts/phpmyadmin.conf";

[[ $? ]] && echo "dream.box added."

exit $?;
