#! /bin/bash

##
# mod_security.sh
#
# Install the mod_security module v2.9.0
# Requires an Apache install (sudo /vagrant/bin/httpd.sh)
#
# https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual#Installation_for_Apache
##

PACKAGE_NAME="modsecurity-2.9.0";

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install autoconf build-essential checkinstall libtool zip;

# Install libraries
apt-get -y install libapr1-dev libaprutil1-dev libpcre3-dev libxml2-dev;

# Link and cache libraries
ldconfig /usr/local/lib;

cd /usr/local/src;

# Download modsecurity-2.9.0
wget https://www.modsecurity.org/tarball/2.9.0/"$PACKAGE_NAME".tar.gz;

# Extract the files
gzip -d "$PACKAGE_NAME".tar.gz;
tar xvf "$PACKAGE_NAME".tar;

cd "$PACKAGE_NAME"/;

# Stop httpd
/etc/init.d/apache2 stop;

# Configure and build
./configure \
--enable-pcre-study=no \
--with-apxs=/usr/local/apache2/bin/apxs;

make;

# Package into a deb file for quick install
#
# Description: modsecurity-2.9.0 compiled from source on 12.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"$PACKAGE_NAME".zip *.deb modsecurity.conf-recommended unicode.mapping;
