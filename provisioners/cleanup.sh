#!/bin/bash

#
# Packer cleanup.
#

set -e;

echo 'Clean out temporary and system files';

# Clean up udev rules.
# Make sure Udev doesn't block our network - http://6.ptmc.org/?p=164
[[ -r /etc/udev/rules.d/70-persistent-net.rules ]] && rm /etc/udev/rules.d/70-persistent-net.rules;
mkdir /etc/udev/rules.d/70-persistent-net.rules;
rm -rf /dev/.udev/;
rm /lib/udev/rules.d/75-persistent-net-generator.rules;

# Clean up dhcp leases.
# Removing leftover leases and persistent rules.
[[ -d '/var/lib/dhcp' ]] && rm /var/lib/dhcp/*;

# Adding a 2 sec delay to the interface up, to make the dhclient happy.
echo 'pre-up sleep 2' >> /etc/network/interfaces;

# Remove temporary files.
[[ -d /tmp/files ]] && rm -rf /tmp/files;

# Cleanup apt cache.
apt-get -y autoremove --purge;
apt-get -y clean;
apt-get -y autoclean;

# Remove Bash history.
unset HISTFILE;
rm -f /root/.bash_history;
rm -f "/home/${SSH_USER}/.bash_history";

# Clean up log files.
find /var/log -type f | while read f; do echo -ne '' > "${f}"; done;

# Clearing last login information.
>/var/log/lastlog;
>/var/log/wtmp;
>/var/log/btmp;

exit $?;
