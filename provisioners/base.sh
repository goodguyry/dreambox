#!/bin/bash
#
# Install packages and move files into place
#

# Expect no interactive input
export DEBIAN_FRONTEND=noninteractive

echo 'Updating repositories'

# Switch to rackspace mirror
perl -p -i -e 's#http://archive.ubuntu.com/ubuntu#http://mirror.rackspace.com/ubuntu#gi' /etc/apt/sources.list

# Add the key for the Git Core PPA
apt-key add /tmp/files/ppa-git-core-key

# Add the git-core PPA
sudo bash -c "echo -e \"deb http://ppa.launchpad.net/git-core/ppa/ubuntu lucid main\" >> /etc/apt/sources.list"
sudo bash -c "echo -e \"deb-src http://ppa.launchpad.net/git-core/ppa/ubuntu lucid main\" >> /etc/apt/sources.list"

# Update apt-get
apt-get -qq update

echo 'Installing packages and libraries'

# Install base packages
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

# Install libraries
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

# Install the packages
dpkg -i /usr/local/src/httpd_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/mysql_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/mod-fastcgi_*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/imagemagick-*.deb > /dev/null 2>&1
dpkg -i /usr/local/src/imagick_*.deb > /dev/null 2>&1

# Additional packages
GIT_VERSION='1:2.3.7-0ppa1~ubuntu10.04.1'
apt-get -y install \
  git-buildpackage \
  git-doc="${GIT_VERSION}" \
  git-man="${GIT_VERSION}" \
  git-sh \
  git-stuff \
  git-svn="${GIT_VERSION}" \
  git="${GIT_VERSION}" \
  ruby \
  ruby-dev \
  ruby-rails-3.2 \
  > /dev/null

# The following NEW packages will be installed:
#   bundler cowbuilder cowdancer dctrl-tools debootstrap devscripts diffstat
#   dput gettext git git-buildpackage git-doc git-man git-sh git-stuff git-svn
#   hardening-includes intltool-debian libapt-pkg-perl libarchive-zip-perl
#   libasprintf-dev libauthen-sasl-perl libautodie-perl libclone-perl
#   libcommon-sense-perl libdigest-hmac-perl libdistro-info-perl
#   libemail-valid-perl libencode-locale-perl liberror-perl
#   libexporter-lite-perl libfile-basedir-perl libfile-listing-perl
#   libfont-afm-perl libgettextpo-dev libgettextpo0 libhtml-form-perl
#   libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl
#   libhtml-tree-perl libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl
#   libhttp-message-perl libhttp-negotiate-perl libio-html-perl libio-pty-perl
#   libio-socket-inet6-perl libio-socket-ssl-perl libio-stringy-perl
#   libipc-run-perl libipc-system-simple-perl libjson-perl libjson-xs-perl
#   liblist-moreutils-perl liblwp-mediatypes-perl liblwp-protocol-https-perl
#   libmailtools-perl libnet-dns-perl libnet-domain-tld-perl libnet-http-perl
#   libnet-ip-perl libnet-smtp-ssl-perl libnet-ssleay-perl
#   libparse-debcontrol-perl libperlio-gzip-perl libserf-1-1 libsocket6-perl
#   libsub-identify-perl libsvn-perl libsvn1 libtext-levenshtein-perl
#   libtie-ixhash-perl libunistring0 liburi-perl libwww-perl
#   libwww-robotrules-perl libxdelta2 libyaml-libyaml-perl libyaml-perl lintian
#   mr myrepos patchutils pbuilder pbzip2 pristine-tar python-dateutil
#   python3-chardet python3-debian python3-magic python3-pkg-resources
#   python3-six rake ruby-actionmailer-3.2 ruby-actionpack-3.2
#   ruby-activemodel-3.2 ruby-activerecord-3.2 ruby-activeresource-3.2
#   ruby-activesupport-3.2 ruby-arel ruby-atomic ruby-blankslate ruby-builder
#   ruby-dev ruby-hike ruby-i18n ruby-journey ruby-mail ruby-minitest
#   ruby-multi-json ruby-net-http-persistent ruby-oj ruby-polyglot
#   ruby-rack-cache ruby-rack-ssl ruby-rack-test ruby-rack1.4 ruby-rails-3.2
#   ruby-railties-3.2 ruby-sprockets ruby-thor ruby-thread-safe ruby-tilt
#   ruby-treetop ruby-tzinfo ruby1.9.1-dev rubygems-integration t1utils wdiff
#   xdelta

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
