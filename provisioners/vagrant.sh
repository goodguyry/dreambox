#!/bin/bash

#
# Vagrant-specific setup.
#

set -e;

# Vagrant specific.
date > /etc/vagrant_box_build_time;

echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant;
chmod 440 /etc/sudoers.d/vagrant;

# Install vagrant keys.
mkdir -pm 700 /home/vagrant/.ssh;
wget --no-check-certificate --quiet 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' \
  -O /home/vagrant/.ssh/authorized_keys;
chmod 0600 /home/vagrant/.ssh/authorized_keys;
chown -R vagrant /home/vagrant/.ssh;

exit $?;
