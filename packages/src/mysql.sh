#! /bin/bash

##
# mysql.sh
#
# Install MySQL 5.6.34
# https://help.ubuntu.com/community/MYSQL5FromSource
##

PACKAGE_NAME="mysql-5.6.34"

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install build-essential checkinstall cmake make zip;

# Install libraries
apt-get -y install libncurses5-dev;

cd /usr/local/src/;

# Download mysql 5.6.34
wget http://dev.mysql.com/get/Downloads/MySQL-5.5/"$PACKAGE_NAME".tar.gz

# Extract the files
gzip -d "$PACKAGE_NAME".tar.gz;
tar xvf "$PACKAGE_NAME".tar;

cd "$PACKAGE_NAME"/;

# Create user and group
groupadd mysql;
useradd -g mysql mysql;

cmake . -DWITH_READLINE=ON -DWITH_LIBEDIT=OFF;
make;

# Package into a deb file for quick install
#
# Description: MySQL 5.6.34 with readline
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"$PACKAGE_NAME".zip *.deb;

# Be sure the MySQL bin is in the PATH
# For this shell
export PATH=$PATH:/usr/local/mysql/bin;
# For future shells
echo "PATH=\"\$PATH:/usr/local/mysql/bin\"" >> /home/vagrant/.profile;
