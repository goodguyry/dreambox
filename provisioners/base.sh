#!/bin/bash
#
# Install packages and move files into place
#

echo 'Installing packages and libraries'

# Expect no interactive input
export DEBIAN_FRONTEND=noninteractive

# Add this repository to SourcesList
perl -p -i -e 's#http://us.archive.ubuntu.com/ubuntu#http://mirror.rackspace.com/ubuntu#gi' /etc/apt/sources.list

# Update apt-get
apt-get -qq update

# Install utilities
apt-get -y install build-essential sysv-rc-conf sysvinit-utils curl facter libreadline5 libreadline6 libreadline6-dev libssl-dev linux-headers-$(uname -r) vim zip zlib1g-dev git git-core git-stuff git-sh git-doc git-svn>/dev/null

# Install libraries
apt-get -y install libapr1 libaprutil1 libaspell15 libcurl3 libdjvulibre21 libfontconfig1 libgvc6 libicu52 libjasper1 libjpeg-turbo8 liblcms1 liblqr-1-0 libltdl7 libmcrypt4 libopenexr6 libpcre3 libpq5 librsvg2-2 libtidy-0.99-0 libtiff5 libwmf0.2-7 libxml2 libxpm4 libxslt1.1 ruby ruby-dev ruby-rails-3.2 >/dev/null

# Link and cache libraries
ldconfig /usr/local/lib

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

update-grub

# Unzip package archives
find /tmp/packages/ -name '*.zip' -exec unzip -d /usr/local/src/ {} \; > /dev/null 2>&1

# Install the packages
dpkg -i /usr/local/src/httpd_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/mysql_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/mod-fastcgi_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/imagemagick-*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/imagick_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/git_*.deb > /dev/null 2>&1

# Link and cache libraries
ldconfig /usr/local/lib

echo 'Copying files into place'

# Copy the PHP FastCGI Wrapper into place and make it executable
cp /tmp/files/php/php-fastcgi-wrapper /usr/local/bin/ && chmod +x /usr/local/bin/php-fastcgi-wrapper

# Apache config files
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

# PHP installers
ls /usr/local/src/php_*.deb 1> /dev/null && cp /usr/local/src/php_*.deb /usr/local/dreambox

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
