#!/bin/bash

#
# Install packages and move files into place.
#

set -e;

# Expect no interactive input.
export DEBIAN_FRONTEND=noninteractive;

# Add the keys for the DH repos.
# @see http://keyserver.ubuntu.com/
apt-key add /usr/local/dreambox/keys/ksplice.key;
apt-key add /usr/local/dreambox/keys/newdream.key;

# Backup the source list.
cp /etc/apt/sources.list /etc/apt/sources.list_bak;

# Update package sources.
bash -c "cat << EOF > /etc/apt/sources.list
deb http://www.ksplice.com/apt trusty ksplice
deb http://debian.di.newdream.net/ trusty ndn
deb http://mirror.newdream.net/ubuntu trusty main universe restricted
deb http://mirror.newdream.net/ubuntu trusty-updates main universe restricted
deb http://mirror.newdream.net/ubuntu trusty-security main universe restricted
EOF";

# Update apt-get.
apt-get -qq update;

echo 'Installing packages and libraries';

# Install base packages.
apt-get -y install \
  build-essential \
  expect \
  sysv-rc-conf \
  tree \
  zip \
  > /dev/null;

# Install libraries.
apt-get -y install \
  libapr1 \
  libaprutil1 \
  libaprutil1-dbd-sqlite3 \
  libaspell15 \
  libdbd-sqlite3-perl \
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
  libsqlite0-dev \
  libsqlite3-dev \
  libssl-dev \
  libtidy-0.99-0 \
  libwmf0.2-7 \
  libxslt1.1 \
  zlib1g-dev \
  > /dev/null;

# Link and cache libraries.
ldconfig /usr/local/lib;

# Tweak sshd to prevent DNS resolution (speed up logins).
bash -c "echo -e '\rUseDNS no' >> /etc/ssh/sshd_config";

# Remove 5s grub timeout to speed up booting.
bash -c "cat << EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF";

update-grub;

# Install additional packages.

echo 'Install miscellaneous packages';
apt-get -y install \
  dh-python \
  git \
  git-buildpackage \
  git-doc \
  git-man \
  git-sh \
  git-stuff \
  git-svn \
  postgresql-client \
  python-pysqlite2 \
  python-sqlite \
  ruby-sqlite3 \
  sqlite \
  subversion \
  subversion-tools \
  > /dev/null;


echo 'Install Apache packages';
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
  > /dev/null;

echo 'Install PHP packages';
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
  > /dev/null;

echo 'Install MySQL packages';
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root';
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root';

apt-get -y install \
  libmysqlclient-dev \
  libmysqlclient18:amd64 \
  libnss-mysql-bg \
  mysql-client-5.6 \
  mysql-client-core-5.6 \
  mysql-server-5.6 \
  mysql-server-core-5.6 \
  mysql-common-5.6 \
  > /dev/null;

echo 'Install Ruby packages';
apt-get -y install \
  ruby \
  ruby-dev \
  ruby-rails-3.2 \
  > /dev/null;

echo 'Install NDN packages';
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
  > /dev/null;

# Add PHP alternatives.
# update-alternatives --set php /usr/local/bin/php-5.6
update-alternatives --install /usr/bin/php php /usr/local/bin/php-5.6 100;
update-alternatives --install /usr/bin/php php /usr/local/bin/php-7.0 100;
update-alternatives --install /usr/bin/php php /usr/local/bin/php-7.1 100;

# Link and cache libraries.
ldconfig /usr/local/lib;

# Install packages used by provider scripts.
apt -y install \
  dkms \
  facter \
  gcc \
  linux-headers-$(uname -r) \
  make \
  perl
  > /dev/null;

# Reboot here to ensure the correct headers are being used.
reboot -f;

exit $?;
