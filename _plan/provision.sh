#!/usr/bin/env bash
# provision.sh — Dreamhost-parity dev environment
# Ubuntu 22.04 Jammy · Apache 2.4 · PHP 8.4 (CGI/FastCGI via php-fpm) · MySQL 8.0
# Mirrors the stack confirmed at ryandomingue.com/info.php

set -euo pipefail

# ---------------------------------------------------------------------------
# 1. System update
# ---------------------------------------------------------------------------
echo "==> Updating package lists..."
apt-get update -y
apt-get install -y software-properties-common ca-certificates apt-transport-https curl

# ---------------------------------------------------------------------------
# 2. Ondrej Sury PPA — the standard source for modern PHP on Ubuntu LTS
# ---------------------------------------------------------------------------
echo "==> Adding Ondrej Sury PHP PPA..."
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2   # keeps Apache closer to current
apt-get update -y

# ---------------------------------------------------------------------------
# 3. Apache 2.4
# ---------------------------------------------------------------------------
echo "==> Installing Apache..."
apt-get install -y apache2

# Enable modules that Dreamhost uses (rewrite, headers, FastCGI proxy)
a2enmod rewrite headers proxy_fcgi setenvif expires deflate include

# Configure VirtualHost: point DocumentRoot at the Eleventy build output (_www/)
# and enable AllowOverride so .htaccess / mod_rewrite rules are honoured.
cat > /etc/apache2/sites-available/000-default.conf <<'VHOST'
<VirtualHost *:80>
    DocumentRoot /var/www/html/_www

    <Directory /var/www/html/_www>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
VHOST

# ---------------------------------------------------------------------------
# 4. PHP 8.4 — CGI/FastCGI via PHP-FPM (matches Dreamhost Server API)
# ---------------------------------------------------------------------------
echo "==> Installing PHP 8.4 and extensions..."
apt-get install -y \
    php8.4-fpm \
    php8.4-cli \
    php8.4-common \
    php8.4-bcmath \
    php8.4-bz2 \
    php8.4-curl \
    php8.4-gd \
    php8.4-intl \
    php8.4-mbstring \
    php8.4-mysql \
    php8.4-opcache \
    php8.4-soap \
    php8.4-sqlite3 \
    php8.4-xml \
    php8.4-xsl \
    php8.4-zip \
    php-imagick

# Wire PHP-FPM into Apache (FastCGI — matches Dreamhost's CGI/FastCGI Server API)
a2enconf php8.4-fpm

# Disable mod_php if it somehow got pulled in — we want FPM only
a2dismod php8.4 2>/dev/null || true

# ---------------------------------------------------------------------------
# 5. php.ini tweaks to match Dreamhost's settings
# ---------------------------------------------------------------------------
echo "==> Configuring php.ini to match Dreamhost..."
PHP_INI=/etc/php/8.4/fpm/php.ini

# Match Dreamhost values from phpinfo()
sed -i 's/^;*short_open_tag\s*=.*/short_open_tag = On/'             "$PHP_INI"
sed -i 's/^;*memory_limit\s*=.*/memory_limit = 128M/'               "$PHP_INI"
sed -i 's/^;*max_execution_time\s*=.*/max_execution_time = 120/'     "$PHP_INI"
sed -i 's/^;*post_max_size\s*=.*/post_max_size = 512M/'              "$PHP_INI"
sed -i 's/^;*upload_max_filesize\s*=.*/upload_max_filesize = 512M/'  "$PHP_INI"
sed -i 's/^;*max_file_uploads\s*=.*/max_file_uploads = 20/'          "$PHP_INI"
sed -i 's/^;*max_input_vars\s*=.*/max_input_vars = 3000/'            "$PHP_INI"
sed -i 's/^;*date.timezone\s*=.*/date.timezone = America\/Los_Angeles/' "$PHP_INI"
sed -i 's/^;*expose_php\s*=.*/expose_php = Off/'                     "$PHP_INI"
sed -i 's/^;*output_buffering\s*=.*/output_buffering = 0/'           "$PHP_INI"
sed -i 's/^;*fastcgi.logging\s*=.*/fastcgi.logging = On/'            "$PHP_INI"

# Development-friendly: show errors locally (Dreamhost has display_errors Off)
# Comment the next two lines out if you want strict production parity.
sed -i 's/^;*display_errors\s*=.*/display_errors = On/'              "$PHP_INI"
sed -i 's/^;*error_reporting\s*=.*/error_reporting = E_ALL/'         "$PHP_INI"

# OPcache — enabled on Dreamhost, JIT disabled
PHP_OPCACHE_INI=/etc/php/8.4/fpm/conf.d/10-opcache.ini
cat > "$PHP_OPCACHE_INI" <<'EOF'
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=0
opcache.memory_consumption=32
opcache.interned_strings_buffer=2
opcache.max_accelerated_files=3907
opcache.revalidate_freq=2
opcache.validate_timestamps=1
opcache.save_comments=1
opcache.jit=disable
opcache.jit_buffer_size=64M
EOF

# ---------------------------------------------------------------------------
# 6. Postfix (sendmail-compatible MTA — required for PHP mail())
# ---------------------------------------------------------------------------
echo "==> Installing Postfix (local MTA for PHP mail())..."
# Pre-seed debconf so postfix installs non-interactively as a local-only MTA.
debconf-set-selections <<'DEBCONF'
postfix postfix/mailname string localhost
postfix postfix/main_mailer_type select Local only
DEBCONF
apt-get install -y postfix
# Confirm sendmail wrapper is in place (postfix provides /usr/sbin/sendmail)
ls /usr/sbin/sendmail

# ---------------------------------------------------------------------------
# 7. MySQL 8.0
# ---------------------------------------------------------------------------
echo "==> Installing MySQL 8.0..."
apt-get install -y mysql-server

# Allow connections from the host machine
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

systemctl enable mysql
systemctl start mysql

# Create a dev user accessible from anywhere (password: vagrant)
mysql -u root <<'SQL'
CREATE USER IF NOT EXISTS 'vagrant'@'%' IDENTIFIED BY 'vagrant';
GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SQL

# ---------------------------------------------------------------------------
# 8. Restart services
# ---------------------------------------------------------------------------
echo "==> Starting services..."
systemctl enable php8.4-fpm
systemctl restart php8.4-fpm
systemctl restart apache2

# ---------------------------------------------------------------------------
# 9. Smoke test
# ---------------------------------------------------------------------------
echo ""
echo "============================================"
echo " Provisioning complete. Environment summary:"
echo "============================================"
apache2 -v
php8.4 -v
mysql --version
echo ""
echo " Server API check:"
php8.4 -r "echo 'Server API: ' . php_sapi_name() . PHP_EOL;"
echo ""
echo " Access your site:"
echo "   http://localhost:8080  (forwarded port)"
echo "   http://192.168.57.10  (private network)"
echo "============================================"
