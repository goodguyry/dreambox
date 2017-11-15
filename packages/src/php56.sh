#! /bin/bash

##
# php.sh
#
# Install PHP v5.6.31
##

PACKAGE_NAME="php-5.6.31"
PHP_DIR="php56"

source php_shared.sh

# Configure and build
./configure \
--datadir=/usr/local/"${PHP_DIR}"/share \
--enable-bcmath \
--enable-calendar \
--enable-cgi \
--enable-ctype \
--enable-dom \
--enable-exif \
--enable-fileinfo \
--enable-filter \
--enable-fpm \
--enable-ftp \
--enable-hash \
--enable-intl \
--enable-json \
--enable-libxml \
--enable-mbregex \
--enable-mbregex-backtrack \
--enable-mbstring \
--enable-opcache \
--enable-pcntl \
--enable-pdo \
--enable-phar \
--enable-posix \
--enable-session \
--enable-shmop \
--enable-simplexml \
--enable-soap \
--enable-sockets \
--enable-sysvmsg \
--enable-sysvsem \
--enable-sysvshm \
--enable-tokenizer \
--enable-wddx \
--enable-xml \
--enable-xmlreader \
--enable-xmlwriter \
--enable-zip \
--localstatedir=/usr/local/"${PHP_DIR}"/var \
--prefix=/usr/local/"${PHP_DIR}" \
--with-bz2 \
--with-config-file-path=/etc/"${PHP_DIR}" \
--with-config-file-scan-dir=/etc/"${PHP_DIR}"/conf.d \
--with-curl \
--with-freetype-dir=/usr \
--with-gd \
--with-gettext \
--with-gmp \
--with-iconv \
--with-imap-ssl \
--with-imap \
--with-jpeg-dir=/usr \
--with-kerberos \
--with-mcrypt \
--with-mhash \
--with-mysql-sock=/tmp/mysql.sock \
--with-mysql=mysqlnd \
--with-mysqli=mysqlnd \
--with-openssl \
--with-pcre-regex \
--with-pdo-mysql=mysqlnd \
--with-pdo-pgsql \
--with-pdo-sqlite \
--with-pgsql \
--with-png-dir=/usr \
--with-pspell \
--with-readline \
--with-sqlite3 \
--with-tidy \
--with-xmlrpc \
--with-xpm-dir=/usr \
--with-xsl \
--with-zend-vm=GOTO \
--with-zlib-dir=/usr \
--with-zlib \
--without-pear \
CFLAGS='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wformat-security' \
CPPFLAGS=-D_FORTIFY_SOURCE=2 \
CXXFLAGS='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Wformat-security' \
LDFLAGS='-Wl,-Bsymbolic-functions -Wl,-z,relro';

make clean;
make;

# Package into a deb file for quick install
#
# Description: PHP 5.6.31 compiled from source on 14.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"${PACKAGE_NAME}".zip *.deb *.ini-*;

# Be sure the PHP bin is in the PATH
# For this shell
export PATH=$PATH:/usr/local/"${PHP_DIR}"/bin;
# For future shells
echo "PATH=\"\$PATH:/usr/local/${PHP_DIR}/bin\"" >> /home/vagrant/.profile;
