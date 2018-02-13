#! /bin/bash

# https://jamielinux.com/docs/openssl-certificate-authority/index.html

#
# Create the root pair
#

# Prepare the directory
sudo mkdir /root/ca
# sudo chmod 755 /root/
cd /root/ca
sudo mkdir certs crl newcerts private
# sudo chmod 700 private
sudo touch index.txt
sudo bash -c "echo 1000 > serial"

# Prepare the configuration file
sudo cp /vagrant/files/ssl/openssl.cnf /root/ca/openssl.cnf

# Create the root key
cd /root/ca
sudo openssl genrsa \
  -aes256 \
  -out private/ca.key \
  4096

# sudo chmod 400 private/ca.key

# Create the root certificate
# cd /root/ca
sudo openssl req \
  -config /root/ca/openssl.cnf \
  -key private/ca.key \
  -new \
  -x509 \
  -days 7300 \
  -sha256 \
  -extensions v3_ca \
  -subj '/C=US/ST=Washington/L=Seattle/O=Dreambox/OU=Dreambox Certificate Authority/CN=Dreambox Root CA/' \
  -out certs/ca.crt

# sudo chmod 444 certs/ca.crt

# Verify the root certificate
sudo openssl x509 -noout -text -in certs/ca.crt

#
# Create the intermediate pair
#

# Prepare the directory
sudo mkdir /root/ca/intermediate
cd /root/ca/intermediate
sudo mkdir certs crl csr newcerts private
# sudo chmod 700 private
sudo touch index.txt
sudo bash -c "echo 1000 > serial"
sudo bash -c "echo 1000 > crlnumber"

sudo cp /vagrant/files/ssl/openssl.intermediate.cnf /root/ca/intermediate/openssl.cnf

# Create the intermediate key
cd /root/ca
sudo openssl genrsa -out intermediate/private/intermediate.key 4096
# also try -nodes

# sudo chmod 400 intermediate/private/intermediate.key

# Create the intermediate certificate
# cd /root/ca
sudo openssl req \
  -config /root/ca/intermediate/openssl.cnf \
  -new \
  -sha256 \
  -subj '/C=US/ST=Washington/L=Seattle/O=Dreambox/OU=Dreambox Certificate Authority/CN=Dreambox Intermediate CA/' \
  -key intermediate/private/intermediate.key \
  -out intermediate/csr/intermediate.csr

# cd /root/ca
sudo openssl ca \
  -config /root/ca/openssl.cnf \
  -extensions v3_intermediate_ca \
  -days 3650 \
  -notext \
  -md sha256 \
  -in intermediate/csr/intermediate.csr \
  -out intermediate/certs/intermediate.crt

# sudo chmod 444 intermediate/certs/intermediate.crt

# Verify the intermediate certificate
sudo openssl x509 -noout -text -in intermediate/certs/intermediate.crt
# Verify the intermediate certificate against the root certificate. An OK indicates that the chain of trust is intact.
sudo openssl verify -CAfile certs/ca.crt intermediate/certs/intermediate.crt
#  > OK

#
# Create the certificate chain file
sudo bash -c "cat intermediate/certs/intermediate.crt certs/ca.crt > intermediate/certs/ca-chain.cert.pem"
# sudo chmod 444 intermediate/certs/ca-chain.cert.pem

# Install the intermediate certificate
# Root CA: /root/ca/certs/ca.crt
# Intermediate CA: /root/ca/intermediate/certs/intermediate.crt

# sudo openssl x509 -in /root/ca/intermediate/certs/intermediate.crt -inform PEM -out /usr/local/share/ca-certificates/intermediate.crt
# sudo openssl x509 -in /root/ca/certs/ca.crt -inform PEM -out /usr/local/share/ca-certificates/ca.crt

# sudo update-ca-certificates
# cp /root/ca/intermediate/certs/ca-chain.cert.pem /vagrant/files/ssl/

# How certificates will be accepted into the ca-certificates package

#
# Create the Root Cert package
#

# Copy this example source package somewhere to build as a normal user,
# for instance your home directory:

# cp -a /usr/share/doc/ca-certificates/examples/ca-certificates-local ~/
# cd ~/ca-certificates-local/

# Remove the dummy CA certificate, copy your local root CA certificate(s)
# to the local/ directory, and build the package:

# @todo This should include all keys and directory structure
# @review Maybe a separate dpkg for the directory structure & keys
# rm local/Local_Root_CA.crt
# cp /root/ca/certs/ca.crt local/
# cp /root/ca/intermediate/certs/intermediate.crt local/
# # cp /root/ca/intermediate/certs/ca-chain.cert.pem local/
# sudo apt-get install -y debhelper
# dpkg-buildpackage
# sudo dpkg -i ../ca-certificates-local_0.1_all.deb

# mkdir -p dreambox-ca-certificates/DEBIAN
cp -a /vagrant/files/dreambox-ca-certificates ~/
cd ~
mkdir dreambox-ca-certificates/root
# Copy the CA directory structure over
sudo cp -a /root/ca dreambox-ca-certificates/root/
# Remove the actual certs
# rm dreambox-ca-certificates/root/ca/certs/*.crt
# rm dreambox-ca-certificates/root/ca/intermediate/certs/*.crt
# - Create a file 'control' in the DEBIAN directory
# For more options see http://www.debian.org/doc/debian-policy/ch-controlfields.html#s-binarycontrolfiles
# touch DEBIAN/control
# - Add a post-installation script. Make sure it is executable. It will run when the installation is complete.
# touch DEBIAN/postinst
dpkg-deb --build dreambox-ca-certificates
sudo cp dreambox-ca-certificates.deb /vagrant/files/debs
# Install the package (or copy it to your local apt repository for
# installation on lots of machines):

# cp ../ca-certificates-local_0.1_all.deb /vagrant/files/ssl/

# Feel free to edit the files under the debian/ directory for items like
# the maintainer name and email address, version, etc. to better reflect
# your own organization. This is just an example to get you started with
# a proper local root CA package.

#################################################################################################################
#################################################################################################################
# Automate from here down
#################################################################################################################
#################################################################################################################

#
# Sign server and client certificates
#

# Create a key
sudo chmod 755 /root/
cd /root/ca
sudo openssl genrsa -out intermediate/private/vhost.key 2048
# sudo chmod 400 intermediate/private/vhost.key

# Create a certificate
sudo openssl req \
  -config /root/ca/intermediate/openssl.cnf \
  -key intermediate/private/vhost.key \
  -new \
  -sha256 \
  -subj '/C=US/ST=Washington/L=Seattle/O=Dreambox/OU=Dreambox Web Services/CN=Dreambox VHost/' \
  -out intermediate/csr/vhost.csr

sudo openssl ca \
  -config /root/ca/intermediate/openssl.cnf \
  -extensions server_cert \
  -days 375 \
  -notext \
  -md sha256 \
  -in intermediate/csr/vhost.csr \
  -out intermediate/certs/vhost.crt

# sudo openssl x509 -noout -in /usr/local/share/ca-certificates/vhost.crt -subject -issuer -dates

# >> expect Sign the certificate? [y/n]:
# >> expect 1 out of 1 certificate requests certified, commit? [y/n]

# SECURE_MYSQL=$(expect -c "
# set timeout 10
# spawn mysql_secure_installation
# expect \"Sign the certificate?\"
# send \"y\r\"
# expect \"1 out of 1 certificate requests certified, commit?\"
# send \"y\r\"
# expect eof
# ");

# echo "${SECURE_MYSQL}";

# sudo chmod 444 intermediate/certs/vhost.crt
# The intermediate/index.txt file should contain a line referring to this new certificate.

# Verify the certificate
sudo openssl x509 -noout -text -in intermediate/certs/vhost.crt

# Use the CA certificate chain file we created earlier (ca-chain.cert.pem) to verify that the new certificate has a valid chain of trust.
sudo openssl verify -CAfile intermediate/certs/ca-chain.cert.pem intermediate/certs/vhost.crt
# > OK

# Copy the key and cert into place
sudo cp intermediate/certs/vhost.crt \
  /usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/

sudo cp intermediate/private/vhost.key \
  /usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/

sudo cp /usr/local/dreambox/ca-chain.cert.pem \
  /usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/

# Copy to /vagrant/certs
[[ ! -d /vagrant/certs ]] && sudo mkdir /vagrant/certs
sudo cp intermediate/certs/vhost.crt /vagrant/certs/
sudo cp intermediate/private/vhost.key /vagrant/certs/
sudo cp intermediate/certs/ca-chain.cert.pem /vagrant/certs/
sudo cp certs/ca.crt /vagrant/certs/


# sudo security add-trusted-cert -d -r trustRoot -k "$HOME/Library/Keychains/login.keychain" certs/ca-chain.cert.pem
# sudo security add-trusted-cert -d -r trustRoot -k "$HOME/Library/Keychains/login.keychain" certs/vhost.crt

#
# Deploy the certificate
#

# SSLCertificateKeyFile /usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/vhost.key
# SSLCertificateFile /usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/vhost.crt
# SSLCertificateChainFile /usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/ca-chain.cert.pem

# https://askubuntu.com/questions/73287/how-do-i-install-a-root-certificate
# https://anonscm.debian.org/cgit/collab-maint/ca-certificates.git/tree/debian/README.Debian
# /usr/share/doc/ca-certificates/examples/ca-certificates-local/README
# https://httpd.apache.org/docs/2.2/mod/mod_ssl.html