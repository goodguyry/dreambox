#! /bin/bash

##
# httpd.sh
#
# Install the httpd (Apache) web server v2.2.22
##

PACKAGE_NAME="httpd-2.2.22";

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install autoconf checkinstall chkconfig libtool make zip;

# Build Apache dependencies
# apt-get -y build-dep apache2

# Link and cache libraries
ldconfig /usr/local/lib;

cd /usr/local/src;

# Download httpd 2.2.22
wget http://archive.apache.org/dist/httpd/"$PACKAGE_NAME".tar.gz;

# Extract the files
gzip -d "$PACKAGE_NAME".tar.gz;
tar xvf "$PACKAGE_NAME".tar;

cd "$PACKAGE_NAME"/;

# Configure and build
./configure \
--disable-autoindex \
--enable-actions \
--enable-cgi \
--enable-deflate \
--enable-expires \
--enable-headers \
--enable-rewrite \
--enable-so \
--enable-ssl \
--enable-unique-id \
--with-included-apr \
--with-included-apr-util;

make;

# Package into a deb file for quick install
#
# Description: Apache 2.2.22 compiled from source on 12.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /vagrant/pkg/"$PACKAGE_NAME".zip *.deb;

# Be sure the Apache bin is in the PATH
# For this shell
export PATH=$PATH:/usr/local/apache2/bin;
# For future shells
echo "PATH=\"\$PATH:/usr/local/apache2/bin\"" >> /home/vagrant/.profile;

