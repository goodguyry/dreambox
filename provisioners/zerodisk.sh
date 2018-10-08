#!/bin/bash

#
# Zero out free space.
#

# Don't capture errors or exit status in this file due to `dd` emitting the
# following error: dd: error writing ‘/EMPTY’: No space left on device

echo 'Clear disk space';

# Whiteout root.
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}');
let count--;
dd if=/dev/zero of=/tmp/whitespace bs=1024 count=$count;
rm /tmp/whitespace;

# Whiteout /boot.
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}');
let count--;
dd if=/dev/zero of=/boot/whitespace bs=1024 count=$count;
rm /boot/whitespace;

# Clear out swap and disable until reboot.
# @review VMWare is failing every time here...
# set +e;
# swapuuid=$(/sbin/blkid -o value -l -s UUID -t TYPE=swap);
# case "$?" in
#     2|0) ;;
#     *) exit 1 ;;
# esac;
# # set -e;
# if [ "x${swapuuid}" != "x" ]; then
#     # Whiteout the swap partition to reduce box size.
#     # Swap is disabled till reboot.
#     swappart=$(readlink -f /dev/disk/by-uuid/$swapuuid);
#     /sbin/swapoff "${swappart}" || echo "swapoff exit code $? is suppressed";
#     dd if=/dev/zero of="${swappart}" bs=1M || echo "dd exit code $? is suppressed";
#     /sbin/mkswap -U "${swapuuid}" "${swappart}" || echo "swapoff exit code $? is suppressed";
# fi

# Zero out the free space to save space in the final image.
dd if=/dev/zero of=/EMPTY bs=1M  || echo "dd exit code $? is suppressed";
rm -f /EMPTY;

# Make sure we wait until all the data is written to disk, otherwise.
# Packer might quite too early before the large files are deleted.
sync;
sync;
sync;
