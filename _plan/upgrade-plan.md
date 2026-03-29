# DreamBox Upgrade Plan: Ubuntu 22.04 + Modern Stack

## Summary of Changes

| Component | Before | After |
|-----------|--------|-------|
| OS | Ubuntu 14.04 LTS | Ubuntu 22.04 LTS |
| Package source | DreamHost NDN repos | Ondrej Sury PPA |
| Apache | 2.2 (custom NDN instance at `/usr/local/dh/apache2/`) | 2.4 (standard at `/etc/apache2/`) |
| PHP | 5.6 / 7.0 / 7.1 via mod_fcgid + CGI | 8.2 / 8.3 / 8.4 / 8.5 via PHP-FPM + proxy_fcgi |
| MySQL | 5.6 | 8.0 |
| Config values | `'56'`, `'70'`, `'71'` | `'82'`, `'83'`, `'84'`, `'85'` |
| Default PHP | `'70'` | `'84'` |
| Test framework | Custom harness | RSpec |

---

## How Per-Site PHP Version Selection Works (Post-Upgrade)

The Ondrej Sury PPA installs each PHP version as a fully independent PHP-FPM service with its own socket:
- `php8.2-fpm` → `/run/php/php8.2-fpm.sock`
- `php8.3-fpm` → `/run/php/php8.3-fpm.sock`
- etc.

Apache's `proxy_fcgi` module routes `.php` requests for each vhost to the correct socket via `SetHandler`. All four FPM versions run simultaneously; per-site version selection is just a matter of which socket path is written into that vhost's `.conf` file.

In `class_config.rb`, the old `php_dir` variable (e.g. `php70`) is replaced by `php_fpm_socket` (e.g. `/run/php/php8.4-fpm.sock`) which is built from the user-supplied PHP version string.

---

## Phase 1: Packer & Base Installer (Ubuntu 22.04)

Ubuntu 22.04 replaces the legacy debian-installer with Subiquity (cloud-init autoinstall). This requires replacing the preseed approach entirely.

### Files to change

**`templates/common.json`**
- Update `iso_url` to Ubuntu 22.04 server ISO
- Update `iso_checksum` and `iso_checksum_type` (use `sha256`)
- Update `virtualbox_guest_os_type` to `Ubuntu_64`
- Update `box_version` to `1.0.0`
- Increase `disk_size` if needed (22.04 base is larger)

**`templates/dreambox.json` — boot commands**

Ubuntu 22.04's Subiquity installer boot command (both builders):
```
"<wait5>",
"e",
"<down><down><down><end>",
" autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/'",
"<f10>"
```

Remove `iso_checksum_type` as a separate field (Packer 1.7+ uses `iso_checksum` with prefix: `sha256:abc123...`).

**`files/preseed/preseed.cfg` → replace with cloud-init autoinstall**

Rename directory to `files/http/` (Packer serves this via HTTP). Create two files:
- `files/http/meta-data` — empty file (required by cloud-init)
- `files/http/user-data` — cloud-init autoinstall config:

```yaml
#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: us
  network:
    network:
      version: 2
      ethernets:
        enp0s3:
          dhcp4: true
  storage:
    layout:
      name: direct
  identity:
    hostname: dreambox
    username: vagrant
    password: "$6$..."   # vagrant, pre-hashed
  ssh:
    install-server: true
    allow-pw: true
  packages:
    - openssh-server
  late-commands:
    - echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/vagrant
    - chmod 440 /target/etc/sudoers.d/vagrant
  user-data:
    disable_root: false
```

Update `http_directory` in `dreambox.json` to point to `files/http/`.

**`templates/dreambox.json` — remove VirtualBox Guest Additions handling**

Ubuntu 22.04 + VirtualBox 7.x uses `virtualbox-guest-utils` from apt; no longer needs the ISO injection approach. Remove `guest_additions_path` and `virtualbox_version_file` from the virtualbox-iso builder. Install `virtualbox-guest-utils` in `provisioners/virtualbox.sh` instead.

---

## Phase 2: Base Provisioner (`provisioners/base.sh`)

Full rewrite. Remove all NDN repo configuration, keys, and packages.

### New structure

```bash
# 1. System prerequisites
apt-get install -y software-properties-common ca-certificates curl

# 2. Ondrej Sury PPA (PHP + modern Apache 2.4)
add-apt-repository -y ppa:ondrej/php
add-apt-repository -y ppa:ondrej/apache2
apt-get update -y

# 3. Apache 2.4
apt-get install -y apache2
a2enmod rewrite headers proxy_fcgi setenvif expires ssl

# 4. All four PHP-FPM versions + shared extensions
# Extensions that apply to all versions: fpm cli common bcmath bz2 curl gd
# imagick intl mbstring mysql opcache soap sqlite3 xml xsl zip
apt-get install -y \
  php8.2-fpm php8.2-{cli,common,bcmath,bz2,curl,gd,imagick,intl,mbstring,mysql,opcache,soap,sqlite3,xml,xsl,zip} \
  php8.3-fpm php8.3-{cli,common,...} \
  php8.4-fpm php8.4-{cli,common,...} \
  php8.5-fpm php8.5-{cli,common,...}

# Enable all FPM conf files
a2enconf php8.2-fpm php8.3-fpm php8.4-fpm php8.5-fpm

# 5. php.ini tweaks (apply to each version's fpm php.ini)
# Match DreamHost values: short_open_tag=On, memory_limit=128M,
# max_execution_time=120, post_max_size=512M, upload_max_filesize=512M,
# max_input_vars=3000, date.timezone=America/Los_Angeles, expose_php=Off,
# output_buffering=0
# OPcache: enabled, JIT disabled (matches DreamHost)

# 6. MySQL 8.0
apt-get install -y mysql-server
# Set root password to 'root', bind-address=0.0.0.0
# Create vagrant user: GRANT ALL ON *.* TO 'vagrant'@'%' IDENTIFIED BY 'vagrant'

# 7. Ruby (for class_config.rb + RSpec tests)
apt-get install -y ruby ruby-dev
gem install bundler

# 8. Misc: git, vim, tree, zip, subversion, sqlite3
# Remove: NDN keys, sysv-rc-conf, dh-python, python-pysqlite2,
#         ruby-rails, ndn-* packages, php alternatives setup
```

### Files to delete
- `files/keys/ksplice.key`
- `files/keys/newdream.key`
- `files/keys/` directory
- `files/php56.conf`, `files/php70.conf`, `files/php71.conf` (replaced by FPM conf mechanism)

---

## Phase 3: Post-Install Provisioners

### `provisioners/setup.apache.sh` — rewrite

Old: Creates a custom Apache instance under `/usr/local/dh/apache2/apache2-dreambox/`.
New: Configures the standard Apache 2.4 install.

```bash
# Create vhost log base directory
mkdir -p /var/log/apache2/dreambox

# Create SSL directory
mkdir -p /etc/apache2/ssl

# Disable default site (dreambox vhosts take over)
a2dissite 000-default

# Enable required modules (already done in base.sh but idempotent here)
a2enmod rewrite headers proxy_fcgi setenvif ssl

# Create the dream.box admin vhost
# (copy files/dreambox-admin.conf to /etc/apache2/sites-available/ and a2ensite)

systemctl enable apache2
```

### `provisioners/setup.mysql.sh` — update

```bash
# MySQL 8.0 uses auth_socket for root by default on Ubuntu
# Switch root to mysql_native_password and set password 'root'
mysql -u root <<SQL
  ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
  CREATE USER IF NOT EXISTS 'vagrant'@'%' IDENTIFIED BY 'vagrant';
  GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
SQL

# Allow remote connections
sed -i 's/^bind-address\s*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
```

### `provisioners/setup.box-host.sh` — minor updates

Update any init.d references to systemctl.

### `provisioners/virtualbox.sh` — update

Remove VBoxGuestAdditions ISO handling. Install from apt:
```bash
apt-get install -y virtualbox-guest-utils virtualbox-guest-dkms
```

### `provisioners/vmware.sh` — update

Install `open-vm-tools` instead of legacy VMware Tools:
```bash
apt-get install -y open-vm-tools
```

---

## Phase 4: Runtime Files (`files/`)

### `files/ndn-vhost.conf` → rename to `files/vhost.conf`

Full rewrite for Apache 2.4 + PHP-FPM:

```apache
<VirtualHost *:80>
  ServerAdmin webmaster@%host%
  ServerName %host%
  # ServerAlias

  DocumentRoot "%document_root%"

  DirectoryIndex index.html index.htm index.php

  SSLEngine off
  # SSLCertificateFile /etc/apache2/ssl/dreambox.crt
  # SSLCertificateKeyFile /etc/apache2/ssl/dreambox.key
  # SSLCertificateChainFile /etc/apache2/ssl/ca-chain.cert.pem

  <Directory "%document_root%">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted

    <FilesMatch "\.php$">
      SetHandler "proxy:unix:%php_fpm_socket%|fcgi://localhost"
    </FilesMatch>
  </Directory>

  LogLevel warn
  ErrorLog "/var/log/apache2/dreambox/%host%/error.log"
  CustomLog "/var/log/apache2/dreambox/%host%/access.log" combined
</VirtualHost>
```

Key changes from old template:
- `Order allow,deny` / `Allow from all` → `Require all granted` (Apache 2.4 syntax)
- `Action php-cgi /cgi-system/php.cgi` → `SetHandler "proxy:unix:..."` (FPM socket)
- `%php_dir%` → `%php_fpm_socket%` (the new variable name)
- Removed `AddHandler cgi-script`, `ExecCGI`, `Include *.conf` directives
- SSL cert paths updated to `/etc/apache2/ssl/`

### `files/vhost.sh` — update

Changes needed:
1. **Vhost file destination**: `/etc/apache2/sites-available/` instead of NDN path
2. **Enable the site**: call `a2ensite "${dict}.conf"` after writing the file
3. **PHP variable**: replace `php_dir` with `php_fpm_socket` in the sed replacement
4. **SSL**: update cert paths (`/etc/apache2/ssl/` not `/usr/local/dh/...`)
5. **Port config**: remove the `ports.conf` editing (Apache 2.4 listens on 80+443 by default when `ssl` module is enabled; `a2ensite` handles it)
6. **Template reference**: `ndn-vhost.conf` → `vhost.conf`

```bash
# Key changes in vhost.sh

vhosts_dir='/etc/apache2/sites-available'
template='/usr/local/dreambox/vhost.conf'   # was ndn-vhost.conf

# After writing conf file, enable the site:
a2ensite "${dict}.conf"

# PHP FPM socket substitution (was php_dir):
sed -i "s|%php_fpm_socket%|${php_fpm_socket}|g" "${vhost_file}"

# SSL cert paths:
# /usr/local/dh/apache2/... → /etc/apache2/ssl/
```

### `files/ssl.sh` — update paths

Replace all `/usr/local/dh/apache2/apache2-dreambox/etc/` references with `/etc/apache2/`. The CA setup logic (openssl, certificate generation) likely remains intact; only the destination paths for `.crt`/`.key`/`.pem` files change.

### `files/httpd.conf` — remove or replace

The custom NDN `httpd.conf` is no longer needed. The standard Apache 2.4 `apache2.conf` handles global configuration. Any DreamHost-parity settings (e.g. `ServerTokens Prod`, `ServerSignature Off`) can be placed in a small snippet at `/etc/apache2/conf-available/dreambox.conf` and enabled via `a2enconf`.

Remove: `files/httpd.conf`, `files/ports.conf`

### `files/set-files.sh` — update references

Update the destination path and file list to match renamed/removed files.

---

## Phase 5: Configuration System (`templates/class_config.rb`)

### Changes to `class_config.rb`

1. **PHP version strings** (line 43–44):
```ruby
# Before:
@php_versions = ['56', '70', '71']
@php_dirs = ['php56', 'php70', 'php71']

# After:
@php_versions = ['82', '83', '84', '85']
@php_fpm_sockets = [
  '/run/php/php8.2-fpm.sock',
  '/run/php/php8.3-fpm.sock',
  '/run/php/php8.4-fpm.sock',
  '/run/php/php8.5-fpm.sock'
]
```

2. **Default PHP version** (line 47):
```ruby
# Before: @php_versions.at(1) → '70'
# After:  @php_versions.at(2) → '84'  (8.4, matching DreamHost panel default)
```

3. **Error message** (line 58): Update accepted values list.

4. **Replace `php_dir` with `php_fpm_socket`** throughout:
   - `site['php_dir']` → `site['php_fpm_socket']`
   - All references to `@php_dirs` → `@php_fpm_sockets`
   - Line 87: `vhosts_dir` → `'/etc/apache2/sites-available/'`
   - Line 139: `site['vhost_file']` path update (now `/etc/apache2/sites-available/dict.conf`)

5. **Subdomain hash** (line 179): update `'php_dir'` key to `'php_fpm_socket'`

6. **`site_defaults`** (line 88–93): replace `'php_dir'` key with `'php_fpm_socket'`

### Changes to `templates/Vagrantfile`

Line 56 — Apache restart:
```ruby
# Before:
inline: "/bin/bash /etc/init.d/httpd2 restart"

# After:
inline: "systemctl restart apache2"
```

Remove the `$user_vars` legacy warning block (lines 15–18) — this was 0.2.x compatibility, now well past relevant.

---

## Phase 6: Test Suite (RSpec Migration)

The custom test harness in `tests/class_tests.rb` / `tests/run.rb` is replaced with RSpec.

### New structure

```
tests/
  Gemfile              # gem 'rspec'
  spec/
    spec_helper.rb     # require class_config, set up shared helpers
    php_spec.rb        # was assertions/php.rb
    user_spec.rb       # was assertions/user.rb
    paths_spec.rb      # was assertions/paths.rb
    aliases_spec.rb    # was assertions/aliases.rb
    subdomains_spec.rb # was assertions/subdomains.rb
    ssl_spec.rb        # was assertions/ssl.rb
    mysql_spec.rb      # was assertions/mysql.rb
    string_methods_spec.rb  # was assertions/string_methods.rb
  configs/
    required.yaml      # update: remove php 56/70/71 references, use 82/84
    typical.yaml       # update: php '84', etc.
    full.yaml          # update: all php versions → 82/83/84/85
```

### Test config updates (`tests/configs/*.yaml`)

All YAML configs need PHP version strings updated:
- `'56'` → `'82'`
- `'70'` → `'84'` (and in default assertions)
- `'71'` → `'85'`

### Run command update

```bash
# Before:
ruby tests/run.rb

# After:
cd tests && bundle exec rspec
# or from repo root:
bundle exec rspec tests/spec/
```

Update `CLAUDE.md` with new test command.

---

## Phase 7: Admin Page & Distribution

### `files/index.php`

Update version references, PHP version links, and any hardcoded NDN/Apache 2.2 paths in the admin landing page.

### `src/ca-setup/`

The `.deb` is fully reproducible from source via two scripts that run inside the VM:
1. `src/ca-setup/ca.sh` — generates the CA (root + intermediate + chain) in `/root/ca/` using OpenSSL
2. `src/ca-setup/package.sh` — assembles and builds the `.deb` with `dpkg-deb --build`, then copies it to `files/`

The package is `Architecture: all` and the OpenSSL commands are identical on 22.04, so **no rebuild is needed for the OS upgrade**. Only the path updates below are required.

**`src/dreambox-ca-certificates/DEBIAN/postinst` — update two paths:**
- `APACHE_SSL_DIR='/usr/local/dh/apache2/apache2-dreambox/etc/ssl.crt/'` → `'/etc/apache2/ssl/'`
- `/usr/local/dh/web/public/` (where `ca-chain.cert.pem` is served for the Firefox import) → new `dream.box` document root

After updating `postinst`, rebuild the `.deb` by running `ca.sh` then `package.sh` inside a VM and committing the resulting `files/dreambox-ca-certificates.deb`.

### `templates/common.json`

Update `box_version` to `1.0.0-beta`.

### `build` script

Verify Packer version compatibility. The current template uses legacy JSON format; Packer 1.7+ supports both JSON and HCL2. If you want to modernize to HCL2 this is the time, but it's optional scope.

---

## Files Changed/Deleted Summary

| Action | File(s) |
|--------|---------|
| Rewrite | `provisioners/base.sh` |
| Rewrite | `provisioners/setup.apache.sh` |
| Update | `provisioners/setup.mysql.sh` |
| Update | `provisioners/virtualbox.sh` |
| Update | `provisioners/vmware.sh` |
| Update | `provisioners/setup.box-host.sh` |
| Rewrite | `files/ndn-vhost.conf` → rename to `files/vhost.conf` |
| Update | `files/vhost.sh` |
| Update | `files/ssl.sh` |
| Update | `files/set-files.sh` (provisioner) |
| Update | `templates/class_config.rb` |
| Update | `templates/Vagrantfile` |
| Update | `templates/common.json` |
| Update | `templates/dreambox.json` (boot commands, http_directory) |
| Update | `files/index.php` |
| Replace | `files/preseed/preseed.cfg` → `files/http/user-data` + `files/http/meta-data` |
| Delete | `files/httpd.conf`, `files/ports.conf` |
| Delete | `files/php56.conf`, `files/php70.conf`, `files/php71.conf` |
| Delete | `files/keys/` directory |
| Migrate | `tests/` → RSpec (new `tests/spec/` structure, add `tests/Gemfile`) |
| Update | `tests/configs/*.yaml` |
| Update | `README.md`, `CLAUDE.md`, `.dreambox/vm-config.yml` |

---

## Suggested Implementation Order

1. **Phase 5 first** — Update `class_config.rb` and run existing tests to validate logic changes before touching infrastructure. This is pure Ruby with no VM dependency.
2. **Phase 6** — Migrate tests to RSpec in parallel or immediately after, so you have a working test suite for Phase 5 changes.
3. **Phase 1 + 2** — Packer template + base.sh together (both define the base box).
4. **Phase 3** — Post-install provisioners.
5. **Phase 4** — Runtime files (vhost.conf, vhost.sh, ssl.sh).
6. **Phase 7** — Admin page and distribution cleanup.
7. Full `./build` run to verify end-to-end.
