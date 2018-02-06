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
    -x509 -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -extensions v3_req \
    -subj "/C=US/ST=Washington/L=Seattle/O=IT/CN=${host}/" \
    -keyout "/usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/${name}.key" \
    -out "/usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/${name}.crt" \
    -config "${open_ssl_conf}";

  # Save these for next time
  [[ ! -d /vagrant/certs ]] && mkdir /vagrant/certs
  cp -f /usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/"${name}".* /vagrant/certs

  if [[ $? -lt 1 ]]; then
    echo -e "SSL certificate created: ${name}.crt\n"
  else
    echo -e "SSL setup error..."
  fi
fi
