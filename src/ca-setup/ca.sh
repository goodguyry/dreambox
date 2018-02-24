#! /bin/bash

#
# Create a Certificate Authority.
# https://jamielinux.com/docs/openssl-certificate-authority/index.html
#

set -e;

SOURCE_DIR='/vagrant/src/ca-setup';

# The directory structure.
declare -a DIRS=(
  /root/ca/certs
  /root/ca/crl
  /root/ca/newcerts
  /root/ca/private
  /root/ca/intermediate/certs
  /root/ca/intermediate/crl
  /root/ca/intermediate/newcerts
  /root/ca/intermediate/private
  /root/ca/intermediate/csr
);

# Files into which content is echoed.
declare -a ECHO_FILES=(
  /root/ca/serial
  /root/ca/intermediate/serial
  /root/ca/intermediate/crlnumber
);

# Create the root pair.

# Prepare the directory structure and files
mkdir /root/ca;
for DIR in ${!DIRS[*]}; do
  [[ ! -d "/tmp/${DIRS[$DIR]}" ]] && mkdir -p "${DIRS[$DIR]}";
done;

touch /root/ca/{,intermediate/}index.txt;
for FILE in ${!ECHO_FILES[*]}; do
  bash -c "echo 1000 > \"${ECHO_FILES[$FILE]}\"";
done;

# Set the configuration files
cp "${SOURCE_DIR}/openssl.intermediate.cnf" /root/ca/intermediate/openssl.cnf;
cp "${SOURCE_DIR}/openssl.cnf" /root/ca/openssl.cnf;

# Create the root key.
openssl genrsa \
  -aes256 \
  -out /root/ca/private/ca.key \
  4096;

# Create the root certificate.
openssl req \
  -config /root/ca/openssl.cnf \
  -key /root/ca/private/ca.key \
  -new \
  -x509 \
  -days 7300 \
  -sha256 \
  -extensions v3_ca \
  -subj '/C=US/ST=Washington/L=Seattle/O=Dreambox/OU=Dreambox Certificate Authority/CN=Dreambox Root CA/' \
  -out /root/ca/certs/ca.crt;

# Create the intermediate key and cert.

# Create the intermediate key
openssl genrsa -out /root/ca/intermediate/private/intermediate.key 4096;

# Create the intermediate certificate
openssl req \
  -config /root/ca/intermediate/openssl.cnf \
  -new \
  -sha256 \
  -subj '/C=US/ST=Washington/L=Seattle/O=Dreambox/OU=Dreambox Certificate Authority/CN=Dreambox Intermediate CA/' \
  -key /root/ca/intermediate/private/intermediate.key \
  -out /root/ca/intermediate/csr/intermediate.csr;

# Sign the intermediate cert
openssl ca \
  -config /root/ca/openssl.cnf \
  -extensions v3_intermediate_ca \
  -days 3650 \
  -notext \
  -md sha256 \
  -in /root/ca/intermediate/csr/intermediate.csr \
  -out /root/ca/intermediate/certs/intermediate.crt;

# Create the certificate chain file
bash -c "cat /root/ca/intermediate/certs/intermediate.crt /root/ca/certs/ca.crt > /root/ca/intermediate/certs/ca-chain.cert.pem";

exit $?;
