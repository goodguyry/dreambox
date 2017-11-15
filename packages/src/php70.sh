#! /bin/bash

##
# php.sh
#
# Install PHP v7.0.24
##

PACKAGE_NAME="php-7.0.24"
PHP_DIR="php70"

source php_shared.sh

# Configure and build
php7_configure

make clean;
make;

# Package into a deb file for quick install
#
# Description: PHP 7.0.24 compiled from source on 14.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"${PACKAGE_NAME}".zip *.deb *.ini-*;

# Be sure the PHP bin is in the PATH
# For this shell
export PATH=$PATH:/usr/local/"${PHP_DIR}"/bin;
# For future shells
echo "PATH=\"\$PATH:/usr/local/${PHP_DIR}/bin\"" >> /home/vagrant/.profile;
