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
  'files'
  'packages'
  'scripts'
  'provisioners'
  'packages'
);

for FILE in ${TMP[@]}; do
  [[ -d "/tmp/${FILE}" ]] && rm -rf "/tmp/${FILE}"
done

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
