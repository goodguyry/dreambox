#! /bin/bash

##
# mysql.sh
#
# Install MySQL 5.5.40
# https://help.ubuntu.com/community/MYSQL5FromSource
##

PACKAGE_NAME="mysql-5.5.40"

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install build-essential checkinstall cmake make zip;

# Install libraries
apt-get -y install libncurses5-dev;

cd /usr/local/src/;

# Download mysql 5.5.40
wget http://dev.mysql.com/get/Downloads/MySQL-5.5/"$PACKAGE_NAME".tar.gz

# Extract the files
gzip -d "$PACKAGE_NAME".tar.gz;
tar xvf "$PACKAGE_NAME".tar;

cd "$PACKAGE_NAME"/;

# Create user and group
groupadd mysql;
useradd -g mysql mysql;

export CHOST="i686-pc-linux-gnu";
export CFLAGS="-mcpu=i686 -march=i686 -O3 -pipe -fomit-frame-pointer";
export CXX=gcc;

cmake .;
make;

# Package into a deb file for quick install
#
# Description: MySQL 5.5.40 compiled from source on 12.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /vagrant/pkg/"$PACKAGE_NAME".zip *.deb;

# Be sure the PHP bin is in the PATH
# For this shell
export PATH=$PATH:/usr/local/mysql/bin;
# For future shells
echo "PATH=\"\$PATH:/usr/local/mysql/bin\"" >> /home/vagrant/.profile;

# Postinstallation setup
# https://dev.mysql.com/doc/refman/5.5/en/installing-source-distribution.html

cd /usr/local/mysql;

# Set permissions
chown -R mysql .
chgrp -R mysql .

# Create GRANT tables
scripts/mysql_install_db --user=mysql

# Reset persmissions
chown -R root .
chown -R mysql data

# Create the conf based in one of the pre-build confs
cp support-files/my-medium.cnf /etc/my.cnf

# Start mysql
mysqld_safe --user=mysql &

# Set mysql to start at boot
cp support-files/mysql.server /etc/init.d/mysql.server

# Set mysql username and password
mysql_secure_installation
