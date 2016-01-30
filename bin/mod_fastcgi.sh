#! /bin/bash

##
# mod_fastcgi.sh
#
# Install the mod_fastcgi module v2.4.6
# Requires an Apache install (sudo /vagrant/bin/httpd.sh)
##

MOD_NAME="mod_fastcgi-2.4.6"

# Be sure the Apache bin is in the PATH
export PATH=$PATH:/usr/local/apache2/bin;

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install make checkinstall zip;

cd /usr/local/src;

# Download mod_fastcgi
wget http://www.fastcgi.com/dist/"$MOD_NAME".tar.gz;

# Unpack the files
tar xvfz "$MOD_NAME".tar.gz;

cd "$MOD_NAME"/;

# Set the Makefile
cp Makefile.AP2 Makefile;

make;

# Package into a deb file for quick install
#
# Description: mod_fastcgi 2.4.6 compiled from source on 12.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /vagrant/pkg/"$MOD_NAME".zip *.deb;
