#! /bin/bash

##
# php.sh
#
# Install PHP v7.0.14
##

PACKAGE_NAME="php-7.0.14"
PHP_DIR="php70"

# TODO The setup is identical and thus can be shared between the two PHP files

# Create some needed directories
mkdir -p /usr/local/"${PHP_DIR}";
mkdir -p /etc/"${PHP_DIR}";

debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password root'

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install build-essential checkinstall make zip;

# Build PHP dependencies
apt-get -y build-dep php5;

# Install additional libraries
apt-get -y install libaspell-dev libc-client2007e-dev libcurl3 libfcgi-dev libfcgi0ldbl libicu-dev libjpeg62-dbg libjpeg8 libmcrypt-dev libpq5 libssl-dev libtidy-dev libxslt1-dev;

# Link the imap library
ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a;

# Link and cache libraries
ldconfig /usr/local/lib;

cd /usr/local/src/;

# Download PHP
wget http://de.php.net/get/"${PACKAGE_NAME}".tar.bz2/from/this/mirror -O "${PACKAGE_NAME}".tar.bz2;

# Unpack the files
tar jxf "${PACKAGE_NAME}".tar.bz2;

cd "${PACKAGE_NAME}"/;

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
--without-pear;

make clean;
make;

# Package into a deb file for quick install
#
# Description: PHP 7.0.14 compiled from source on 12.04
# Hit return through all prompts
checkinstall -D make install;

# Zip it into the synced directory
zip /tmp/packages/"${PACKAGE_NAME}".zip *.deb *.ini-*;

# Be sure the PHP bin is in the PATH
# For this shell
export PATH=$PATH:/usr/local/"${PHP_DIR}"/bin;
# For future shells
echo "PATH=\"\$PATH:/usr/local/${PHP_DIR}/bin\"" >> /home/vagrant/.profile;
