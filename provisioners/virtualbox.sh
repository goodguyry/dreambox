#!/bin/bash

#
# VirtualBox-specific setup.
#

set -e;

# Bail if we are not running inside VirtualBox.
if [[ `facter virtual` != "virtualbox" ]]; then
    exit 0;
fi;

# Install the VMWare Tools from a linux ISO.
mkdir -p /mnt/virtualbox;
mount -o loop /home/vagrant/VBoxGuest*.iso /mnt/virtualbox;

sh /mnt/virtualbox/VBoxLinuxAdditions.run;
ln -s /opt/VBoxGuestAdditions-*/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions;

umount /mnt/virtualbox;
rm -rf /home/vagrant/VBoxGuest*.iso;

exit $?;
