#!/bin/bash

#
# Zero out free space.
#

# Don't capture errors or exit status in this file due to `dd` emitting the
# following error: dd: error writing ‘/EMPTY’: No space left on device

# Zero out the free space to save space in the final image.
dd if=/dev/zero of=/EMPTY bs=1M;
rm -f /EMPTY;

# Sync to ensure that the delete completes before this moves on.
sync;
sync;
sync;
