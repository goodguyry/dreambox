#!/bin/bash

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

# Make sure Udev doesn't block our network
echo "cleaning up udev rules"
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

declare -a PACKAGES=(
  '/usr/local/src/httpd_2.2.31-1_amd64.deb'
  '/usr/local/src/imagemagick-6.6.9_10-1_amd64.deb'
  '/usr/local/src/imagick_3.2.0RC1-1_amd64.deb'
  '/usr/local/src/mod-fastcgi_2.4.6-1_amd64.deb'
  '/usr/local/src/mysql_5.5.40-1_amd64.deb'
);

for INDEX in ${!PACKAGES[*]}; do
  if [[ -r "${PACKAGES[$INDEX]}" ]]; then
    sudo rm -f "${PACKAGES[$INDEX]}"
  fi
done

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
