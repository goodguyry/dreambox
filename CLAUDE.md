# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Does

DreamBox recreates the DreamHost shared hosting environment as a Vagrant box. It uses Packer to build VirtualBox and VMware base images and Vagrant to provision per-project development environments. The box is distributed via Vagrant Cloud as `goodguyry/dreambox`.

## Commands

**Build boxes:**
```bash
./build                  # Build both VirtualBox and VMware
./build virtualbox       # Build only VirtualBox
./build vmware           # Build only VMware
```

**Run tests:**
```bash
ruby tests/run.rb
```

Tests exercise `templates/class_config.rb` against YAML configs in `tests/configs/` using assertions in `tests/assertions/`.

## Architecture

### Configuration System

`templates/class_config.rb` is the central piece — it parses `.dreambox/vm-config.yml` from the user's project and emits environment variables consumed by provisioner shell scripts. It handles:
- PHP version inheritance (global default → site override)
- UID/GID assignment (UIDs from 501, GIDs from 901)
- SSL SAN list generation
- Subdomain configuration (subdomains inherit parent site settings)

`templates/utilities.rb` provides shared helpers used by the config class and Vagrantfile.

### Two-Phase Provisioning

**Phase 1 — Box build (Packer):** `provisioners/` scripts run once during box creation via `templates/dreambox.json`. Order: `set-files.sh` → `base.sh` (packages) → reboot → Apache/MySQL setup → provider-specific → cleanup/zerodisk.

**Phase 2 — Runtime (Vagrant):** When a user runs `vagrant up`, `templates/Vagrantfile` drives provisioning using scripts deployed to `/usr/local/dreambox/` inside the box: `ssl.sh`, `user.sh`, `vhost.sh`. These are parameterized via environment variables produced by `class_config.rb`.

### Key File Locations

- `templates/dreambox.json` — Packer template (builders, provisioners, post-processors)
- `templates/common.json` — Packer variables (Ubuntu ISO, box version, VM specs)
- `templates/Vagrantfile` — Packaged Vagrantfile included in distributed `.box` files
- `files/` — Static files copied into the box at `/usr/local/dreambox/`
- `files/ndn-vhost.conf` — Apache vhost template
- `_builds/` — Output directory for built `.box` files (not committed)
- `src/ca-setup/` — Scripts to generate the CA and build `files/dreambox-ca-certificates.deb`

### Packages

Uses DreamHost's NDN repositories to install packages that exactly match DreamHost production: `ndn-apache22`, `ndn-php56`/`php70`/`php71`, `mysql-server-5.6`. This is the reason for the custom APT keys in `files/keys/`.

### Inside the Box

After `vagrant up`, the box exposes:
- **Per-site files:** `/home/<username>/<root>/`
- **Apache config:** `/usr/local/dh/apache2/apache2-dreambox/` with vhosts in `etc/vhosts/`
- **Apache logs:** `/var/log/apache2/dreambox/<host>/`
- **Apache restart:** `sudo /etc/init.d/httpd2 restart`
- **MySQL restart:** `sudo /etc/init.d/mysql restart`
- **MySQL credentials:** root/root, vagrant/vagrant
- **phpMyAdmin:** `http://dream.box/phpmyadmin/` (connect to host `127.0.0.1`)
- **Admin page:** `http://dream.box` — links to phpMyAdmin and CA cert download
- **CA cert (for Firefox):** download `ca-chain.cert.pem` from the admin page; import via Firefox Preferences → Certificates → Authorities

### CA Certificate Package

`files/dreambox-ca-certificates.deb` is built from source via two scripts that run inside a VM:
1. `src/ca-setup/ca.sh` — generates root + intermediate CA and chain file under `/root/ca/`
2. `src/ca-setup/package.sh` — assembles and builds the `.deb`, copies it to `files/`

### User Configuration (`vm-config.yml`)

Users place `.dreambox/vm-config.yml` alongside their Vagrantfile. The file path can be overridden by declaring `config_file` in the Vagrantfile before the box loads.

Global options: `php` (default `'70'`), `ssl` (default `false`), `debug` (default `false`).

Each site requires: `host`, `root`, `sync`, `username`. Optional: `php`, `ssl`, `database`, `aliases`, `public`, `subdomains`, `group`.

Subdomains are defined as a hash under a site and automatically inherit the parent's `username`, `uid`, `group`, `gid`, `php`, and `ssl`.

SSH into provisioned users with `vagrant` as the password; all users have passwordless `sudo`.

### Test Structure

Tests load assertion modules from `tests/assertions/` automatically. Each module tests one aspect of `class_config.rb` behavior against configs in `tests/configs/` (`required.yaml`, `typical.yaml`, `full.yaml`). The test harness in `tests/class_tests.rb` tracks pass/fail counts and prints expected vs. actual on failure.
