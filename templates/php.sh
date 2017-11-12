#! /bin/bash

echo "Installing PHP v${php}"
if [[ /usr/local/src/php_"${php}"*.deb ]]; then
  dpkg -i /usr/local/src/php_"${php}"*.deb > /dev/null 2>&1
else
  exit 1
fi

# Copy the .ini file into place
mkdir -p /etc/"${php_dir}"
cp /usr/local/dreambox/php.ini /etc/"${php_dir}"/

# Copy php-cgi to the Apache cgi-bin
cp /usr/local/"${php_dir}"/bin/php-cgi /usr/local/apache2/cgi-bin/

# Update the PHP version in fastcgi wrapper
if [[ 'php56' != "${php_dir}" ]]; then
  sed -i "s/\(php56\)/${php_dir}/" /usr/local/bin/php-fastcgi-wrapper
fi

# Update bin path
export PATH=$PATH:"/usr/local/${php_dir}/bin"
echo "PATH=\$PATH:/usr/local/${php_dir}/bin" >> /home/vagrant/.profile

# Restart Apache
echo "Starting Apache"
/etc/init.d/apache2 start
