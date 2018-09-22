#!/bin/bash

#
# Set up the box host.
#

set -e;
set -u;

# Set the new vhost conf file in place.
cp /usr/local/dreambox/ndn-vhost.conf /usr/local/dh/apache2/apache2-dreambox/etc/vhosts/dream.box.conf;

# Create vhost log directory.
[[ ! -d /var/log/apache2/dreambox/dream.box ]] && mkdir -p /var/log/apache2/dreambox/dream.box;

# Add the index.php file
cp /tmp/files/index.php /dh/web/;

# Set Apache directory.
ESCAPED_DOCUMENT_ROOT=$(echo "/dh/web" | sed 's/\(\W\)/\\\1/g');
sed -i "s/%document_root%/${ESCAPED_DOCUMENT_ROOT}/g" /usr/local/dh/apache2/apache2-dreambox/etc/vhosts/dream.box.conf;

# Update hostname throughout.
sed -i -r "s/%host%/dream.box/g" /usr/local/dh/apache2/apache2-dreambox/etc/vhosts/dream.box.conf;

# Add the domains to /etc/hosts
echo "127.0.0.1 dream.box" >> /etc/hosts;

# Set the CGI script based on the PHP version
sed -i -r "s/%php_dir%/php56/g" /usr/local/dh/apache2/apache2-dreambox/etc/vhosts/dream.box.conf;

[[ $? ]] && echo "dream.box added."

exit $?;
