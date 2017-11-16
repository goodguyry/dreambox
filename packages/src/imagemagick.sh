#! /bin/bash

##
# imagemagick.sh
#
# Install ImageMagick v6.7.7-10
##

PACKAGE_NAME="ImageMagick-6.7.7-10"

# Be sure the PHP bin is in the PATH
export PATH=$PATH:/usr/local/php56/bin;

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install autoconf build-essential checkinstall sysv-rc-conf sysvinit-utils libtool make pkg-config zip php5-dev;

# Build ImageMagick dependencies
apt-get -y install build-dep imagemagick; # E: Unable to locate package build-dep

# Link and cache libraries
ldconfig /usr/local/lib;

# ImageMagick

cd /usr/local/src;

# Download ImageMagick 6.7
wget https://sourceforge.net/projects/imagemagick/files/old-sources/6.x/6.7/"$PACKAGE_NAME".tar.gz;
# https://pilotfiber.dl.sourceforge.net/project/imagemagick/old-sources/6.x/6.7/ImageMagick-6.7.7-10.tar.gz

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
# Description: ImageMagick 6.7.7-10 compiled from source on 14.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"$PACKAGE_NAME".zip *.deb;
