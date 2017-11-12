#!/bin/bash

# Removing leftover leases and persistent rules
echo "Cleaning up dhcp leases"
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo "Cleaning up udev rules"
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

# Remove temporary directories
echo "Removing temporary files"
declare -a TMP=(
  '/tmp/files'
  '/tmp/packages'
  '/tmp/scripts'
  '/tmp/templates'
);

for INDEX in ${!TMP[*]}; do
  [[ -d $TMP[$INDEX] ]] && rm -rf $TMP[$INDEX]
done

echo "Removing .deb installers"
declare -a PACKAGES=(
  /usr/local/src/httpd_*.deb
  /usr/local/src/imagemagick-*.deb
  /usr/local/src/imagick_*.deb
  /usr/local/src/mod-fastcgi_*.deb
  /usr/local/src/mysql_*.deb
);

for INDEX in ${!PACKAGES[*]}; do
  ls $PACKAGES[$INDEX] 1> /dev/null && rm -f $PACKAGES[$INDEX]
done

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
