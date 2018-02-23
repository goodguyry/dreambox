#!/bin/bash
#
# Create the site's user and group
#

# Create the group
if grep -q $group /etc/group; then
  echo "Group ${group} already exists";
else
  addgroup --gid $gid $group;
fi;

# Create the user
if $(getent passwd $user >/dev/null); then
  echo "User ${user} already exists.";
else
  adduser --no-create-home -uid $uid -gid $gid --disabled-password --gecos '' $user;
  cp -R /home/vagrant/.ssh "/home/${user}/.ssh";
  echo -e "vagrant\nvagrant" | (passwd $user);
  cp /home/vagrant/.profile "/home/${user}/.profile";
  echo "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers;
fi;

# Update permissions
chown -R "${user}:${group}" "/home/${user}";
