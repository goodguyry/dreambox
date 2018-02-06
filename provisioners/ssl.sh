#!/bin/bash
#
# Create the SSL certificate, then finish setup
#

open_ssl_conf='/usr/lib/ssl/dreambox-openssl.cnf'

# Check for a saved certificate and key
if [[ -r "/vagrant/certs/${name}.key" && -r "/vagrant/certs/${name}.crt" ]]; then
  echo "Using saved certs from /vagrant/certs/"
  cp -f /vagrant/certs/"${name}".* /usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/
else
  if [[ -n "${hosts}" ]]; then
    # Enable the alt_names pointer
    sed -i -r 's/(#\s)(subjectAltName\s=\s\@alt_names)/\2/' "${open_ssl_conf}"
    # Add the DNS Hosts string to `open_ssl_conf`
    bash -c "echo -e \"${hosts}\" >> ${open_ssl_conf}"
  fi

  # Create the certificate
  openssl req \
    -x509 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -extensions v3_req \
    -subj "/C=US/ST=Washington/L=Seattle/O=IT/CN=${host}/" \
    -keyout "/usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/${name}.key" \
    -out "/usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/${name}.crt" \
    -config "${open_ssl_conf}";

#
# https://forums.freebsd.org/threads/62285/
#
# openssl.conf
# [ san_cert ]
# basicConstraints    = CA:FALSE
# nsRevocationUrl     = https://XXXXXXX.XXX/otCA.crl
# subjectAltName      = ${ENV::SAN}
# extendedKeyUsage    = serverAuth
#
# Here is how you issue a CA cert:
#
# openssl req \
#   -new \
#   -x509 \
#   -newkey rsa:2048 \
#   -sha256 \
#   -days 3650 \
#   -extensions v3_ca \
#   -keyout private/cakey.pem \
#   -out cacert.pem \
#   -config ../openssl.cnf
#
# You'll need to configure openssl.cnf to use your new CA. Try this guide: http://www.freebsdmadeeasy.com/tutorials/freebsd/create-a-ca-with-openssl.php
#
# These are the commands I use to issue the server cert. Note the SAN variable. It is a comma separated list. Any domain you want to be able to access your web server from should be in the list. For example if your hostname is fbsd and your FQDN is fbsd.home:
#
# openssl req \
#   -new \
#   -newkey rsa:2048 \
#   -sha256 \
#   -nodes \
#   -out fbsd-req.pem \
#   -keyout private/fbsd.pem \
#   -config ../openssl.cnf
#
# export SAN=DNS:fbsd,DNS:fbsd.home
# openssl ca \
#   -config /etc/ssl/openssl.cnf \
#   -extensions san_cert \
#   -md sha256 \
#   -out certs/fbsd.pem \
#   -infiles reqs/fbsd-req.pem
#

  # Save these for next time
  [[ ! -d /vagrant/certs ]] && mkdir /vagrant/certs
  cp -f /usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/"${name}".* /vagrant/certs

  if [[ $? -lt 1 ]]; then
    echo -e "SSL certificate created: ${name}.crt\n"
  else
    echo -e "SSL setup error..."
  fi
fi
