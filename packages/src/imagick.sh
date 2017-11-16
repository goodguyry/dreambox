#! /bin/bash

##
# imagick.sh
#
# Install imagick v3.4.3
# Requires a PHP install (sudo ./vagrant/packages/src/php56.sh)
##

MOD_NAME="imagick-3.4.3";

cd /usr/local/src;

# Download imagick
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
# Description: imagick 3.4.3 compiled from source on 14.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"$MOD_NAME".zip *.deb;
