#! /bin/bash

#
# Create the Root Cert package.
#

set -e;

PKG_NAME='dreambox-ca-certificates';
SOURCE_DIR='/vagrant/src';
PKG_DIR="${SOURCE_DIR}/${PKG_NAME}";

# Set up the source directory.
cp -a "${PKG_DIR}" $HOME;
cd $HOME;

# Create directories.
mkdir "${PKG_NAME}/root";
mkdir -p "${PKG_NAME}/usr/local/dreambox/";

# Copy the /root/ca directory structure.
cp -a /root/ca "${PKG_NAME}/root/";
# Copy the chain file into the dreambox directory.
cp "${PKG_NAME}/root/ca/intermediate/certs/ca-chain.cert.pem" "${PKG_NAME}/usr/local/dreambox/";

# Build the deb package
dpkg-deb --build "${PKG_NAME}";
# Copy to repo
cp "${PKG_NAME}.deb" /vagrant/files/;

exit $?;
