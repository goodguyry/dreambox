#!/bin/bash

#
# Packer cleanup.
#

set -e;

echo 'Clean out temporary and system files';

# Clean up dhcp leases.
# Removing leftover leases and persistent rules.
rm /var/lib/dhcp/*;

# Clean up udev rules.
# Make sure Udev doesn't block our network.
[[ -r /etc/udev/rules.d/70-persistent-net.rules ]] && rm /etc/udev/rules.d/70-persistent-net.rules;
mkdir /etc/udev/rules.d/70-persistent-net.rules;
rm -rf /dev/.udev/;
rm /lib/udev/rules.d/75-persistent-net-generator.rules;

# Remove temporary files.
[[ -d /tmp/files ]] && rm -rf /tmp/files;

# Adding a 2 sec delay to the interface up, to make the dhclient happy.
echo 'pre-up sleep 2' >> /etc/network/interfaces;

exit $?;
