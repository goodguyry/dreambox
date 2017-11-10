#!/bin/bash

# Expect no interactive input
export DEBIAN_FRONTEND=noninteractive

# Add this repository to SourcesList
perl -p -i -e 's#http://us.archive.ubuntu.com/ubuntu#http://mirror.rackspace.com/ubuntu#gi' /etc/apt/sources.list

# Update apt-get
echo "Updating apt-get"
apt-get -qq update

# Install utilities
echo "Installing utilities"
apt-get -y install build-essential chkconfig curl facter libreadline-gplv2-dev libssl-dev linux-headers-$(uname -r) vim zip zlib1g-dev git git-core git-stuff git-sh git-doc git-svn>/dev/null

# Install libraries
echo "Installing libraries"
apt-get -y install libapr1 libaprutil1 libaspell15 libcurl3 libdjvulibre21 libfontconfig1 libgvc5 libicu48 libjasper1 libjpeg-turbo8 liblcms1 liblqr-1-0 libltdl7 libmcrypt4 libopenexr6 libpcre3 libpq5 librsvg2-2 libtidy-0.99-0 libtiff4 libwmf0.2-7 libxml2 libxpm4 libxslt1.1  ruby1.8-dev ruby-rails-2.3 >/dev/null

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

# Unzip the archives
echo "Unziping the archives"
find /tmp/packages/ -name '*.zip' -exec unzip -d /usr/local/src/ {} \; > /dev/null 2>&1

# Install the packages
echo "Installing the packages"
dpkg -i /usr/local/src/httpd_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/mysql_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/mod-fastcgi_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/imagemagick-*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/imagick_*.deb > /dev/null 2>&1

# Link and cache libraries
ldconfig /usr/local/lib

# Copy files into place
echo "Copying files into place"

# Copy the PHP FastCGI Wrapper into place
cp /tmp/files/php/php-fastcgi-wrapper /usr/local/bin/
# Make it executable
chmod +x /usr/local/bin/php-fastcgi-wrapper

# Copy the Apache config files into place
[[ ! -d '/usr/local/apache2/conf/vhosts' ]] && mkdir '/usr/local/apache2/conf/vhosts'
cp /tmp/files/http/httpd.conf /usr/local/apache2/conf/
cp /tmp/files/http/ports.conf /usr/local/apache2/conf/vhosts/

# Copy SSL setup script into place
cp /tmp/files/dreambox-openssl.cnf /usr/lib/ssl/dreambox-openssl.cnf

# Add Apache, PHP and MySQL bins to PATH
echo "Adding Apache, PHP and MySQL bins to PATH"

# For this shell
export PATH=$PATH:/usr/local/apache2/bin
export PATH=$PATH:/usr/local/mysql/bin

# For all future shells
echo "PATH=\$PATH:/usr/local/apache2/bin" >> /home/vagrant/.profile
echo "PATH=\$PATH:/usr/local/mysql/bin" >> /home/vagrant/.profile

# Set up motd
# Remove existing files
rm -f /etc/update-motd.d/*
# Copy Dreambox motd in place
for MOTD in /tmp/files/motd/*; do
  cp "${MOTD}" /etc/update-motd.d/
done
# Make new files executable
chmod +x /etc/update-motd.d/*
