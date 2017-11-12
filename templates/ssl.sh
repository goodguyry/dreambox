#!/bin/bash
#
# Create the SSL certificate, then finish setup
#
open_ssl_conf='/usr/lib/ssl/dreambox-openssl.cnf'

# Check for a saved certificate and key
if [[ -r "/vagrant/certs/${name}.key" && -r "/vagrant/certs/${name}.crt" ]]; then
  # Use the saved certs
  echo "Using saved certs from /vagrant/certs/"
  cp -f /vagrant/certs/"${name}".* /usr/local/apache2/conf/
else
  if [ -z "${hosts}" ]; then
    # Comment-out alt_names pointer
    sed -i 's/\(subjectAltName\ =\ \@alt_names\)/# \1/' "${open_ssl_conf}"
  else
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
    -keyout "/usr/local/apache2/conf/${name}.key" \
    -out "/usr/local/apache2/conf/${name}.crt" \
    -config "${open_ssl_conf}";

  # Create the certs directory
  [[ ! -d /vagrant/certs ]] && mkdir /vagrant/certs
  # Save these for next time
  cp -f /usr/local/apache2/conf/"${name}".* /vagrant/certs
fi

if [[ $? -lt 1 ]]; then
  echo -e "SSL certificate created: ${name}.crt\n"
else
  echo -e "SSL setup error..."
fi
