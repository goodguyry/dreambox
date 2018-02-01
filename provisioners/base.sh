#!/bin/bash
#
# Install packages and move files into place
#

# Expect no interactive input
export DEBIAN_FRONTEND=noninteractive

echo 'Updating apt sources.list'

# Add the keys for the DH repos
apt-key add /tmp/files/keys/ksplice-key
apt-key add /tmp/files/keys/newdream-key

# Backup the source list
cp /etc/apt/sources.list /etc/apt/sources.list_bak

bash -c "cat << EOF > /etc/apt/sources.list
deb http://www.ksplice.com/apt trusty ksplice
deb http://debian.di.newdream.net/ trusty ndn
deb http://mirror.newdream.net/ubuntu trusty main universe restricted
deb http://mirror.newdream.net/ubuntu trusty-updates main universe restricted
deb http://mirror.newdream.net/ubuntu trusty-security main universe restricted
EOF"

# Update apt-get
apt-get -qq update

echo 'Installing packages and libraries'

# Install base packages
apt-get -y install \
  build-essential \
  sysv-rc-conf \
  zip \
  > /dev/null

# Install libraries
apt-get -y install \
  libapr1 \
  libaprutil1 \
  libaspell15 \
  libdjvulibre21 \
  libgvc6 \
  liblcms1 \
  liblqr-1-0 \
  libmcrypt4 \
  libopenexr6 \
  libpq5 \
  libreadline5 \
  libreadline6-dev \
  librsvg2-2 \
  libssl-dev \
  libtidy-0.99-0 \
  libwmf0.2-7 \
  libxslt1.1 \
  zlib1g-dev \
  > /dev/null

# Link and cache libraries
ldconfig /usr/local/lib

# Tweak sshd to prevent DNS resolution (speed up logins)
bash -c "echo 'UseDNS no' >> /etc/ssh/sshd_config"

# Remove 5s grub timeout to speed up booting
bash -c "cat << EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF"

update-grub

# Additional packages

echo "Install Git packages"
apt-get -y install \
  git \
  git-buildpackage \
  git-doc \
  git-man \
  git-sh \
  git-stuff \
  git-svn \
  > /dev/null

echo "Install Apache packages"
apt-get -y install \
  ndn-apache-helper \
  ndn-apache22 \
  ndn-apache22-modcband \
  ndn-apache22-modcloudflare \
  ndn-apache22-modfastcgi \
  ndn-apache22-modfcgid \
  ndn-apache22-modhtscanner \
  ndn-apache22-modlimitipconn \
  ndn-apache22-modpagespeed \
  ndn-apache22-modsecurity2 \
  ndn-apache22-modxsendfile \
  ndn-apache22-svn \
  > /dev/null

echo "Install PHP packages"
apt-get -y install \
  ndn-php56 \
  ndn-php56-imagick \
  ndn-php56-mongo \
  ndn-php56-xcache \
  ndn-php70 \
  ndn-php70-imagick \
  ndn-php70-mongo \
  ndn-php71 \
  ndn-php71-imagick \
  ndn-php71-mongo \
  > /dev/null

echo "Install MySQL packages"
apt-get -y install \
  mysql-client \
  > /dev/null

echo "Install Ruby packages"
apt-get -y install \
  ruby \
  ruby-dev \
  ruby-rails-3.2 \
  > /dev/null

echo "Install NDN packages"
apt-get -y install \
  ndn-analog \
  ndn-areca \
  ndn-clientscripts \
  ndn-daemontools \
  ndn-debuglogging \
  ndn-dh-base \
  ndn-dh-web-missing \
  ndn-dh-web-parking \
  ndn-dovecot \
  ndn-imagemagick-policy \
  ndn-iptables \
  ndn-keyring \
  ndn-libopenipmi0 \
  ndn-localdata \
  ndn-megacli \
  ndn-misc \
  ndn-netsaint-plugins openipmi- \
  ndn-ntp-client \
  ndn-openipmi \
  ndn-passenger \
  ndn-procwatch \
  ndn-savelog \
  ndn-sdbm-util \
  ndn-sendarp \
  ndn-smart-check \
  ndn-twcli \
  > /dev/null

# Add PHP alternatives
# update-alternatives --set php /usr/local/bin/php-5.6
update-alternatives --install /usr/bin/php php /usr/local/bin/php-5.6 100
update-alternatives --install /usr/bin/php php /usr/local/bin/php-7.0 100
update-alternatives --install /usr/bin/php php /usr/local/bin/php-7.1 100

# Link and cache libraries
ldconfig /usr/local/lib

echo 'Copying files into place'

# # Provisioners and support files
declare -a FILES=(
  'files/http/httpd-vhosts.conf'
  'files/http/ndn-vhost.conf'
  'files/php/php.ini'
  'provisioners/php.sh'
  'provisioners/ssl.sh'
  'provisioners/user.sh'
  'provisioners/vhost.sh'
)

[[ ! -d /usr/local/dreambox ]] && mkdir /usr/local/dreambox
for INDEX in ${!FILES[*]}; do
  [[ -r "/tmp/${FILES[$INDEX]}" ]] && cp "/tmp/${FILES[$INDEX]}" /usr/local/dreambox/
done

# SSL config
cp /tmp/files/ssl/dreambox-openssl.cnf /usr/lib/ssl/dreambox-openssl.cnf

# Apache setup

# Create VHosts directory
[[ ! -d /dh/apache2/template/etc/extra/vhosts ]] && mkdir /dh/apache2/template/etc/extra/vhosts
# cp /tmp/files/http/httpd.conf /usr/local/apache2/conf/
# cp /tmp/files/http/ports.conf /dh/apache2/template/etc/extra/vhosts/

echo "Replacing strings in configuration files"

# Change httpd2 init script to use /bin/bash
sed -i -r 's/(#! )(\/bin\/sh)/\1 \/bin\/bash/' /etc/init.d/httpd2;

# Load mod_fcgid
sed -i -r '/LoadModule rewrite_module.*\.so/a LoadModule fcgid_module lib/modules/mod_fcgid.so' \
  /dh/apache2/template/etc/httpd.conf;
# Include the VHost directory
sed -i -r 's/(#)(Include etc\/extra\/)httpd-vhosts\.conf/\2vhosts\/\*/' \
  /dh/apache2/template/etc/httpd.conf;

# Duplicate template
cp -r /dh/apache2/template /dh/apache2/apache2-dreambox;
# Move httpd file to template root
ln -s /dh/apache2/apache2-dreambox/sbin/httpd /dh/apache2/apache2-dreambox/apache2-dreambox-httpd;
# Change the config paths
sed -i -r 's/(\/usr\/local\/dh\/apache2\/)(template)/\1apache2-dreambox/' \
  /dh/apache2/apache2-dreambox/etc/httpd.conf;
# Set the PID path
sed -i -r '/ServerRoot \"\/usr\/local\/dh\/apache2\//a PidFile "/var/run/apache2-dreambox-httpd.pid"' \
  /dh/apache2/apache2-dreambox/etc/httpd.conf;

# Create the logs directory
# @TODO This could likely change to whatever... it just needs to match what's in ndn-vhost.conf
mkdir -p /home/_domain_logs/vagrant/dreambox.http/http.dreambox-instance;
# Copy the test vhost.conf into place
# @TODO Once this is finalized, move to template with placeholder strings
cp /vagrant/ndn-vhost.conf /dh/apache2/apache2-dreambox/etc/extra/vhosts/;
# Create test domain path
# @TODO Remove after testing
mkdir -p /home/vagrant/dreambox.http;
# Add a PHP info test page
# @TODO Remove after testing
bash -c "echo '<?php phpinfo(); ?>' >> /home/vagrant/dreambox.http/index.php";

# Start Apache
/etc/init.d/httpd2 start;

# # Remove existing motd and set up ours
rm -f /etc/update-motd.d/*
for MOTD in /tmp/files/motd/*; do
  MOTD_FILE=${MOTD##*/}
  cp "${MOTD}" /etc/update-motd.d/ && chmod +x /etc/update-motd.d/"${MOTD_FILE}"
done
