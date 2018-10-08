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

echo "Installing VirtualBox guest additions";
# Assuming the following packages are installed.
# apt-get install -y linux-headers-$(uname -r) build-essential perl.

VBOX_VERSION=$(cat /home/vagrant/.vbox_version);

# Install the VMWare Tools from a linux ISO.
mount -o loop "/home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso" /mnt;
sh /mnt/VBoxLinuxAdditions.run;

umount /mnt;
rm "/home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso";
rm /home/vagrant/.vbox_version;

if [[ $VBOX_VERSION = "4.3.10" ]]; then
    ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions;
fi;
