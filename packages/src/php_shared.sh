
# Create some needed directories
mkdir -p /usr/local/"${PHP_DIR}";
mkdir -p /etc/"${PHP_DIR}";
mkdir -p /tmp/packages/;

debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password root'

# Update apt-get
apt-get -qq update;

# Install utilities
apt-get -y install \
  build-essential \
  checkinstall \
  make \
  mcrypt \
  mlock \
  zip \
  ;

# Build PHP dependencies
apt-get -y build-dep php5;

# Install additional libraries
apt-get -y install \
  libc-client2007e \
  libc-client2007e-dev \
  libfcgi-dev \
  libfcgi0ldbl \
  libjpeg62 \
  libjpeg62-dbg \
  libmcrypt-dev \
  libmcrypt4 \
  libreadline-dev \
  ;

# Link the imap library
ln -s /usr/lib/libc-client.a /usr/lib/x86_64-linux-gnu/libc-client.a;
ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h;

# Link and cache libraries
ldconfig /usr/local/lib;

cd /usr/local/src/;

# Download PHP
wget http://us2.php.net/get/"${PACKAGE_NAME}".tar.bz2/from/this/mirror -O "${PACKAGE_NAME}".tar.bz2;

# Unpack the files
tar jxf "${PACKAGE_NAME}".tar.bz2;

cd "${PACKAGE_NAME}"/;

function php7_configure() {
  # configure: WARNING: unrecognized options: --with-zend-vm
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
}
