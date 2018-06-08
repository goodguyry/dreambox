#!/bin/bash

#
# VirtualBox-specific setup.
#

# Don't capture errors or exit status in this file due to GuestAdditions
# installation emitting a supposedly non-error fail message.
# https://www.virtualbox.org/ticket/17189#comment:3

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
