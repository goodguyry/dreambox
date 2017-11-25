#!/bin/bash
#
# Install packages and move files into place
#

echo 'Installing packages and libraries'

# Expect no interactive input
export DEBIAN_FRONTEND=noninteractive

# Add this repository to SourcesList
perl -p -i -e 's#http://us.archive.ubuntu.com/ubuntu#http://mirror.rackspace.com/ubuntu#gi' /etc/apt/sources.list

# Update apt-get
apt-get -qq update

echo "Install base packages"
apt-get -y install \
  build-essential \
  sysv-rc-conf \
  zip \
  > /dev/null

# The following NEW packages will be installed:
#   build-essential dpkg-dev g++ g++-4.8 libalgorithm-diff-perl
#   libalgorithm-diff-xs-perl libalgorithm-merge-perl libcurses-perl
#   libcurses-ui-perl libdpkg-perl libfile-fcntllock-perl libstdc++-4.8-dev
#   libterm-readkey-perl sysv-rc-conf unzip zip
# 0 upgraded, 16 newly installed, 0 to remove and 10 not upgraded.

echo "Install libraries"
apt-get -y install \
  libapr1 \
  libaprutil1 \
  libaspell15 \
  libdjvulibre21 \
  libgvc6 \
  liblcms1 \
  liblqr-1-0 \
  libmcrypt4 \
  libopenexr6 \
  libpq5 \
  libreadline5 \
  libreadline6-dev \
  librsvg2-2 \
  libssl-dev \
  libtidy-0.99-0 \
  libwmf0.2-7 \
  libxslt1.1 \
  zlib1g-dev \
  > /dev/null

# The following NEW packages will be installed:
#   aspell aspell-en dictionaries-common gsfonts libapr1 libaprutil1 libaspell15
#   libcdt5 libcgraph6 libcroco3 libdjvulibre-text libdjvulibre21 libgvc6
#   libilmbase6 liblcms1 liblqr-1-0 libmcrypt4 libopenexr6 libpathplan4 libpq5
#   libreadline5 libreadline6-dev librsvg2-2 librsvg2-common libssl-dev
#   libssl-doc libtidy-0.99-0 libtinfo-dev libwmf0.2-7 libxslt1.1 zlib1g-dev
# 0 upgraded, 31 newly installed, 0 to remove and 10 not upgraded.

# Link and cache libraries
ldconfig /usr/local/lib

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

update-grub

# Unzip package archives
find /tmp/packages/ -name '*.zip' -exec unzip -d /usr/local/src/ {} \; > /dev/null 2>&1

echo "Install the packages"
dpkg -i /usr/local/src/httpd_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/mysql_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/mod-fastcgi_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/imagemagick-*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/imagick_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/git_*.deb > /dev/null 2>&1

echo "Additional packages"
apt-get -y install \
  git-doc \
  git-sh \
  git-svn \
  ruby \
  ruby-dev \
  ruby-rails-3.2 \
  > /dev/null

# The following NEW packages will be installed:
#   bundler git-doc git-man git-sh git-svn liberror-perl libserf-1-1 libsvn-perl
#   libsvn1 libyaml-libyaml-perl libyaml-perl rake ruby-actionmailer-3.2
#   ruby-actionpack-3.2 ruby-activemodel-3.2 ruby-activerecord-3.2
#   ruby-activeresource-3.2 ruby-activesupport-3.2 ruby-arel ruby-atomic
#   ruby-blankslate ruby-builder ruby-dev ruby-hike ruby-i18n ruby-journey
#   ruby-mail ruby-minitest ruby-multi-json ruby-net-http-persistent ruby-oj
#   ruby-polyglot ruby-rack-cache ruby-rack-ssl ruby-rack-test ruby-rack1.4
#   ruby-rails-3.2 ruby-railties-3.2 ruby-sprockets ruby-thor ruby-thread-safe
#   ruby-tilt ruby-treetop ruby-tzinfo ruby1.9.1-dev rubygems-integration
# The following packages will be upgraded:
#   git
# 1 upgraded, 46 newly installed, 1 to remove and 10 not upgraded.

# dpkg: ruby-rack: dependency problems, but removing anyway as you requested:
#  chef-zero depends on ruby-rack.

# Preparing to unpack .../git_1%3a1.9.1-1ubuntu0.7_amd64.deb ...
# stat:
# cannot stat ‘/usr/lib/git-core/git-add’
# : No such file or directory
# dpkg: error processing archive /var/cache/apt/archives/git_1%3a1.9.1-1ubuntu0.7_amd64.deb (--unpack):
#  subprocess new pre-installation script returned error exit status 1
# Selecting previously unselected package git-man.
# dpkg: considering deconfiguration of git, which would be broken by installation of git-man ...
# dpkg: yes, will deconfigure git (broken by git-man)
# Preparing to unpack .../git-man_1%3a1.9.1-1ubuntu0.7_all.deb ...

# Errors were encountered while processing:
#  /var/cache/apt/archives/git_1%3a1.9.1-1ubuntu0.7_amd64.deb
# E
# :
# Sub-process /usr/bin/dpkg returned an error code (1)

# Link and cache libraries
ldconfig /usr/local/lib

echo 'Copying files into place'

# Copy the PHP FastCGI Wrapper into place and make it executable
cp /tmp/files/php/php-fastcgi-wrapper /usr/local/bin/ && chmod +x /usr/local/bin/php-fastcgi-wrapper

# Apache config files
[[ ! -d /usr/local/apache2/conf/vhosts ]] && mkdir /usr/local/apache2/conf/vhosts
cp /tmp/files/http/httpd.conf /usr/local/apache2/conf/
cp /tmp/files/http/ports.conf /usr/local/apache2/conf/vhosts/

# Provisioners and support files
declare -a FILES=(
  'files/http/httpd-vhosts.conf'
  'files/php/php.ini'
  'provisioners/php.sh'
  'provisioners/ssl.sh'
  'provisioners/user.sh'
  'provisioners/vhost.sh'
)

[[ ! -d /usr/local/dreambox ]] && mkdir /usr/local/dreambox
for INDEX in ${!FILES[*]}; do
  [[ -r "/tmp/${FILES[$INDEX]}" ]] && cp "/tmp/${FILES[$INDEX]}" /usr/local/dreambox/
done

# PHP installers
ls /usr/local/src/php_*.deb 1> /dev/null && cp /usr/local/src/php_*.deb /usr/local/dreambox

# SSL config
cp /tmp/files/ssl/dreambox-openssl.cnf /usr/lib/ssl/dreambox-openssl.cnf

# Add Apache, PHP and MySQL bins to PATH"
# For this shell and all future shells
export PATH=$PATH:/usr/local/apache2/bin
export PATH=$PATH:/usr/local/mysql/bin
echo "PATH=\$PATH:/usr/local/apache2/bin" >> /home/vagrant/.profile
echo "PATH=\$PATH:/usr/local/mysql/bin" >> /home/vagrant/.profile

# Remove existing motd and set up ours
rm -f /etc/update-motd.d/*
for MOTD in /tmp/files/motd/*; do
  MOTD_FILE=${MOTD##*/}
  cp "${MOTD}" /etc/update-motd.d/ && chmod +x /etc/update-motd.d/"${MOTD_FILE}"
done
