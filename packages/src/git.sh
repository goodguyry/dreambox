#! /bin/bash

##
# git.sh
#
# Install Git v2.7.3
##

PACKAGE_NAME='git-2.7.3'

apt-get -qq update

declare -a PACKAGES=(
  asciidoc
  autoconf
  checkinstall
  curl
  docbook2x
  getopt
  gettext
  libcurl4-openssl-dev
  libexpat1-dev
  make
  xmlto
  zip
  zlib1g-dev
)

for INDEX in ${!PACKAGES[*]}; do
  apt-get -y install "${PACKAGES[$INDEX]}"
done

cd /usr/local/src

wget https://www.kernel.org/pub/software/scm/git/"${PACKAGE_NAME}".tar.gz

tar -xvzf "${PACKAGE_NAME}".tar.gz

cd "${PACKAGE_NAME}"

make configure

./configure --prefix=/usr/local/git

make all doc info

# Package into a deb file for quick install
#
# Description: Git 2.7.3 compiled from source on 14.04
# Hit return through all prompts
checkinstall -D make install install-doc install-html install-info

# Zip it into the synced directory
mkdir -p /tmp/packages/
zip /tmp/packages/"$PACKAGE_NAME".zip *.deb
