#! /bin/bash

##
# imagick.sh
#
# Install ImageMagick and imagick
# - ImageMagick v6.6.9-10
# - imagick v3.2.0RC1
# Both require a PHP install (sudo /vagrant/bin/php.sh)
##

PACKAGE_NAME="ImageMagick-6.6.9-10"
# 6.7.7.10

# Be sure the PHP bin is in the PATH
export PATH=$PATH:/usr/local/php56/bin;

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install autoconf build-essential checkinstall sysv-rc-conf sysvinit-utils libtool make pkg-config zip;

# Build ImageMagick dependencies
apt-get -y install build-dep imagemagick;

# Link and cache libraries
ldconfig /usr/local/lib;

# ImageMagick

cd /usr/local/src;

# Download ImageMagick 6.6.9
wget https://sourceforge.net/projects/imagemagick/files/old-sources/6.x/6.6/"$PACKAGE_NAME".tar.gz;

# Unpack the files
tar xvzf "$PACKAGE_NAME".tar.gz;

cd "$PACKAGE_NAME"/;

# Configure and build
./configure \
--libdir=/usr/lib/x86_64-linux-gnu/ \
--prefix=/usr/local \
--with-bzlib=yes \
--with-djvu=yes \
--with-dps=yes \
--with-fontconfig=yes \
--with-freetype=yes \
--with-gslib=yes \
--with-gvc=yes \
--with-jbig=yes \
--with-jp2=yes \
--with-jpeg=yes \
--with-png=yes \
--with-tiff=yes \
--with-wmf=yes \
--with-x=yes;

make clean;
make;

# Package into a deb file for quick install
#
# Description: ImageMagick 6.6.9 compiled from source on 12.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"$PACKAGE_NAME".zip *.deb;

# imagick

MOD_NAME="imagick-3.2.0RC1";
# 3.4.3

cd /usr/local/src;

# Download imagick 3.2 RC1
wget http://pecl.php.net/get/"$MOD_NAME".tgz;

# Unpack the files
tar xvzf "$MOD_NAME".tgz;

cd "$MOD_NAME"/;

# Prepare the build environment for a PHP extension
/usr/local/php56/bin/phpize;

# Configure and build
./configure;

make;

# Package into a deb file for quick install
#
# Description: imagick 3.2.0RC1 compiled from source on 12.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"$MOD_NAME".zip *.deb;
