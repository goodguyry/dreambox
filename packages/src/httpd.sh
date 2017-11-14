#! /bin/bash

##
# httpd.sh
#
# Install the httpd (Apache) web server v2.2.31
##

PACKAGE_NAME="httpd-2.2.31";

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install autoconf checkinstall sysv-rc-conf sysvinit-utils libtool make zip;

# Build Apache dependencies
apt-get -y build-dep apache2

# Link and cache libraries
ldconfig /usr/local/lib;

cd /usr/local/src;

# Download httpd
wget http://archive.apache.org/dist/httpd/"$PACKAGE_NAME".tar.gz;

# Extract the files
gzip -d "$PACKAGE_NAME".tar.gz;
tar xvf "$PACKAGE_NAME".tar;

cd "$PACKAGE_NAME"/;

# Configure and build
# https://httpd.apache.org/docs/2.2/programs/configure.html
./configure \
--enable-mods-shared='all actions alias autoindex cgi deflate expires headers rewrite ssl unique-id' \
--enable-actions \
--enable-alias \
--enable-autoindex \
--enable-cgi \
--enable-deflate \
--enable-expires \
--enable-headers \
--enable-rewrite \
--enable-ssl \
--enable-unique-id \
--with-included-apr \
--with-included-apr-util;

make;

# Package into a deb file for quick install
#
# Description: Apache 2.2.31 compiled from source on 14.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"$PACKAGE_NAME".zip *.deb;

# Be sure the Apache bin is in the PATH
# For this shell
export PATH=$PATH:/usr/local/apache2/bin;
# For future shells
echo "PATH=\"\$PATH:/usr/local/apache2/bin\"" >> /home/vagrant/.profile;

