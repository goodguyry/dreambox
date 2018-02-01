#! /bin/bash
#
# Install PHP
#

echo "Installing PHP v${php}"

if [[ /usr/local/dreambox/php_"${php}"*.deb ]]; then
  dpkg -i /usr/local/dreambox/php_"${php}"*.deb > /dev/null 2>&1
else
  exit 1
fi

# cp:
# cannot stat ‘/usr/local/php70/bin/php-cgi’
# : No such file or directory
# httpd (pid 12775) already running

# Copy the .ini file into place
mkdir -p /etc/"${php_dir}"
cp /usr/local/dreambox/php.ini /etc/"${php_dir}"/

# Copy php-cgi to the Apache cgi-bin
cp /usr/local/"${php_dir}"/bin/php-cgi /usr/local/apache2/cgi-bin/

# Update the PHP version in fastcgi wrapper
if [[ 'php56' != "${php_dir}" ]]; then
  sed -i "s/php56/${php_dir}/" /usr/local/bin/php-fastcgi-wrapper
fi

# Update bin path
export PATH=$PATH:"/usr/local/${php_dir}/bin"
echo "PATH=\$PATH:/usr/local/${php_dir}/bin" >> /home/vagrant/.profile

# Start Apache
/etc/init.d/apache2 start
