DreamBox
========

> Recreates the DreamHost shared hosting environment as a Vagrant box.

**Version 0.2.x contains breaking changes to the Vagrantfile setup. See [upgrading Dreambox][upgrading_dreambox] for more information.**

This project repo contains the code for [building the Dreambox base box][wiki_build]. To use Dreambox in your project, check out the ["Getting Started" section of the Wiki][getting_started].

## Package Versions

Ubuntu `14.04 LTS`

| Package           | Version    |
| ------------------|------------|
| ndn-php56         | 5.6.36     |
| ndn-php70         | 7.0.30     |
| ndn-php71         | 7.1.19     |
| ndn-apache22      | 2.2.31-5   |
| mysql-server-5.6  | 5.6.33     |

The following are installed, but may require additional configuration and/or packages (Contributions are welcome and appreciated):
* Perl
* PostgreSQL
* Python
* Ruby
* SQLite

See [the Wiki][getting_started] for additional documentation.

## References

- https://help.dreamhost.com/hc/en-us/articles/217141627-Supported-and-unsupported-technologies

## CHANGELOG

### 0.3.0-beta-1

> **BREAKING CHANGES in 0.3.x: See [Upgrading-Dreambox][upgrading_dreambox]**

- ADDED: Uses Dreamhost NDN repositories ([#36](../../issues/36))
  - Prefixed with `ndn-` in `dpkg -l`
- ADDED: Create multiple vhosts during vagrant up ([#5](../../issues/5))
- ADDED: Choose between multiple PHP versions
- ADDED: Run more than one version of PHP
- ADDED: Certificate Authority (no more self-signed certificates) ([#54](../../issues/54))
- ADDED: Subdomain support
- ADDED: Support for a public root
- ADDED: Support for host aliases
- ADDED: `.dreambox` directory
- CHANGED: Moves configuration to external YAML file
- CHANGED: Updates Ubuntu to `14.04.5`
- CHANGED: Updates MySQL to `5.6.33`
- CHANGED: Updates PHP to versions `5.6.33`, `7.0.27`, and `7.1.13`
- CHANGED: Build scripts improved for a more streamlined VM.
- FIXED: Corrects user home directory permissions.
- FIXED: Uses `subjectAltName` for all hosts
	- [commonName matching is deprecated](https://groups.google.com/a/chromium.org/forum/m/#!topic/security-dev/IGT2fLJrAeo)
- REMOVED: Configuration via a hash of settings values

### 0.2.5

- ADDED: A message about testing Dreambox `0.3.0-beta-1`

### 0.2.4

- FIXED: SSL no longer automatically enabled ([#37](../../issues/37))

### 0.2.3

- ADDED: Git
- ADDED: Ruby 1.8
- ADDED: Public folder setting
- ADDED: Passwordless `sudo` for all users
- ADDED: Log in with provisioned user
- CHANGED: Reverts `useradd` removal
- FIXED: Invalid MySQL socket path
- FIXED: Sets correct sync folder permissions

Thanks to [@jbtule](https://github.com/jbtule) and [@meowsus](https://github.com/meowsus).

### 0.2.2

- ADDED: Initial SSL support ([#1](../../issues/1))
- CHANGED: Updates MySQL to use readline
- CHANGED: Updates PHP to `5.6.29`
- CHANGED: Updates Apache to `2.2.31`
- CHANGED: Sets `test` as primary development VM and prevents `dev` autostart
- CHANGED: Updates motd with Wiki links
- REMOVED: Removes `userdel` from `user_setup`

### 0.2.1

- CHANGED: Moves documentation to [the Wiki](Home)
- FIXED: Adds missing Vagrantfile template

### 0.2.0

> **BREAKING CHANGES on 0.2.x: See [Upgrading-Dreambox][upgrading_dreambox]**

- ADDED: Example Vagrantfile
- ADDED: Packaged Vagrantfile to simplify the setup process
- CHANGED: The main sync folder for the web root is now created automatically ([#7](../../issues/7))
- CHANGED: `user_setup` is now automatically run during `vagrant up`
- FIXED: Fixed MySQL autostart ([#9](../../issues/9))
- FIXED: Build error when `dropbox_pre` isn't found
- REMOVED: Removes ModSecurity ([#10](../../issues/10))
- REMOVED: `user_setup` no longer creates a user

Thanks to [@NReilingh](https://github.com/NReilingh).

### 0.1.1

- ADDED: Dreambox Message of the Day (motd)
- ADDED: Compiled package files
- CHANGED: Cleaned up documentation (more to come...)
- CHANGED: Disabled Sendfile [mitchellh/vagrant#351 (comment)](https://github.com/mitchellh/vagrant/issues/351#issuecomment-1339640)
- CHANGED: Restructured source files and development workflow
- CHANGED: Enabled and loaded shared Apache modules
- FIXED: An issue preventing sites from displaying when accessed via IP address ([#4](../../issues/4))
- FIXED: Broken MySQL build script
- FIXED: PROJECT_ROOT variable used by `user_setup`
- FIXED: Broken package source URLs ([#3](../../issues/3))

### 0.1.0

Initial release

[getting_started]: ../../wiki/Home
[wiki_build]: ../../wiki/Building-Dreambox
[upgrading_dreambox]: ../../wiki/Upgrading-Dreambox
