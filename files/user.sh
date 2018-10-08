#!/bin/bash

#
# Create the site's user and group.
#

set -e;
set -u;

# Create the group.
if grep -q $group /etc/group; then
  echo "Group ${group} already exists";
else
  addgroup --gid $gid $group;
fi;

# Create the user.
if $(getent passwd $username >/dev/null); then
  echo "User ${username} already exists.";
else
  adduser --no-create-home -uid $uid -gid $gid --disabled-password --gecos '' $username;
  cp -R /home/vagrant/.ssh /home/$username/.ssh;
  echo -e "vagrant\nvagrant" | (passwd $username);
  cp /home/vagrant/.profile /home/$username/.profile;
  echo "${username} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$username;
  chmod 440 /etc/sudoers.d/$username;
fi;

# Update home directory permissions.
chown -R "${username}:${group}" "/home/${username}";

exit $?;
