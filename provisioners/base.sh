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
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
cat << EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

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

# install-info: warning: no info dir entry in `/usr/share/info/dist.info.gz'
# update-rc.d: warning:  stop runlevel arguments (none) do not match httpd2 Default-Stop values (0 1 4 6)
# update-rc.d: warning:  start runlevel arguments (none) do not match httpd2 Default-Start values (2 3)
# update-rc.d: warning:  stop runlevel arguments (4) do not match httpd2 Default-Stop values (0 1 4 6)
#  System start/stop links for /etc/init.d/httpd2 already exist.

# Install PHP packages

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

# dpkg: ruby-rack: dependency problems, but removing anyway as you requested:
#  chef-zero depends on ruby-rack.

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

# ndn-netsaint-plugins (installs openipmi) apt-get install ndn-netsaint-plugins openipmi-
# Setting up ipmitool (1.8.13-1ubuntu0.6) ...
# * Starting IPMI event daemon
# Could not open device at /dev/ipmi0 or /dev/ipmi/0 or /dev/ipmidev/0: No such file or directory
# invoke-rc.d: initscript ipmievd, action "start" failed.
# Unable to start ipmievd during installation.  Trying to disable.
#
# lsmod
# service --status-all
# service openipmi start
# modprobe ipmi_msghandler
# modprobe ipmi_devintf
# modprobe ipmi_si
#
#
# ndn-procwatch:
# Starting process-watching daemon: /dh/etc/procwatch/on doesn't exist -- exiting.
#
# ndn-clientscripts:
# * Running checkuptime: Bad response; retrying (2 tries left) at /usr/local/dh/bin/checkuptime.pl line 7.
# Bad response; retrying (1 tries left) at /usr/local/dh/bin/checkuptime.pl line 7.
# SSL_cert_file /usr/local/dh/etc/xmlrpc-physical.crt does not exist at /usr/share/perl5/IO/Socket/SSL.pm line 1637. at /usr/local/dh/bin/checkuptime.pl line 7.
#
# insserv: warning: script 'K01standby' missing LSB tags and overrides
# insserv: warning: script 'friendly-recovery' missing LSB tags and overrides
# insserv: warning: script 'standby' missing LSB tags and overrides
# insserv: warning: script 'cron' missing LSB tags and overrides

# Add PHP alternatives
# update-alternatives --set php /usr/local/bin/php-5.6
update-alternatives --install /usr/bin/php php /usr/local/bin/php-5.6 100
update-alternatives --install /usr/bin/php php /usr/local/bin/php-7.0 100
update-alternatives --install /usr/bin/php php /usr/local/bin/php-7.1 100

# Link and cache libraries
ldconfig /usr/local/lib

echo 'Copying files into place'

# Copy the PHP FastCGI Wrapper into place and make it executable
cp /tmp/files/php/php-fastcgi-wrapper /usr/local/bin/ && chmod +x /usr/local/bin/php-fastcgi-wrapper

# Apache config files
# /usr/local/dh/apache2/template/etc/extra/
[[ ! -d /usr/local/apache2/conf/vhosts ]] && mkdir /usr/local/apache2/conf/vhosts
cp /tmp/files/http/httpd.conf /usr/local/apache2/conf/
cp /tmp/files/http/ports.conf /usr/local/apache2/conf/vhosts/

# Provisioners and support files
declare -a FILES=(
  'files/http/httpd-vhosts.conf'
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

# Add Apache, PHP and MySQL bins to PATH"
# For this shell and all future shells
export PATH=$PATH:/usr/local/apache2/bin
export PATH=$PATH:/usr/local/mysql/bin
echo "PATH=\$PATH:/usr/local/apache2/bin" >> /home/vagrant/.profile
echo "PATH=\$PATH:/usr/local/mysql/bin" >> /home/vagrant/.profile

# Remove existing motd and set up ours
rm -f /etc/update-motd.d/*
for MOTD in /tmp/files/motd/*; do
  MOTD_FILE=${MOTD##*/}
  cp "${MOTD}" /etc/update-motd.d/ && chmod +x /etc/update-motd.d/"${MOTD_FILE}"
done
