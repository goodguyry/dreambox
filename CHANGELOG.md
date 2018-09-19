# CHANGELOG

## 0.3.0-beta-1

**BREAKING CHANGES in 0.3.x: See [Upgrading-Dreambox](Upgrading-Dreambox)**

- ADDED: Uses Dreamhost NDN repositories
  - #36
  - Prefixed with `ndn-` in `dpkg -l`
- ADDED: Create multiple vhosts during vagrant up ([#5](../issues/5))
- ADDED: Choose between multiple PHP versions
- ADDED: Run more than one version of PHP
- ADDED: Certificate Authority (no more self-signed certificates)
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

> **BREAKING CHANGES in 0.2.x: See [Upgrading-Dreambox](Upgrading-Dreambox)**

## 0.2.5

- ADDED: A message about testing Dreambox `0.3.0-beta`

## 0.2.4

- FIXED: SSL no longer automatically enabled ([#37](../issues/37))

## 0.2.3

- FIXED: Invalid MySQL socket path ([#25](../issues/25)) ([@meowsus](../../../meowsus))
- ADDED: Git ([@jbtule](../../../jbtule))
- ADDED: Ruby 1.8 ([@jbtule](../../../jbtule))
- ADDED: Public folder setting ([@jbtule](../../../jbtule))
- CHANGED: Reverts `useradd` removal ([@jbtule](../../../jbtule))
- FIXED: Sets correct sync folder permissions
- ADDED: Passwordless `sudo` for all users
- ADDED: Log in with provisioned user

## 0.2.2

- CHANGED: Updates MySQL to use readline
- CHANGED: Updates PHP to `5.6.29`
- CHANGED: Updates Apache to `2.2.31`
- CHANGED: Sets `test` as primary development VM and prevents `dev` autostart
- REMOVED: Removes `userdel` from `user_setup`
- CHANGED: Updates motd with Wiki links
- ADDED: Initial SSL support

## 0.2.1

- FIXED: Adds missing Vagrantfile template
- CHANGED: Moves documentation to [the Wiki](Home)

## 0.2.0

- REMOVED: Removes ModSecurity
- FIXED: Fixed MySQL autostart ([#9](../issues/9)) ([@NReilingh](../../../NReilingh))
- REMOVED: `user_setup` no longer creates a user
- CHANGED: The main sync folder for the web root is now created automatically
- ADDED: Example Vagrantfile
- CHANGED: `user_setup` is now automatically run during `vagrant up`
- ADDED: Packaged Vagrantfile to simplify the setup process
- FIXED: Build error when `dropbox_pre` isn't found

## 0.1.1

- ADDED: Dreambox Message of the Day (motd)
- FIXED: An issue preventing sites from displaying when accessed via IP address
- ADDED: Compiled package files
- CHANGED: Cleaned up documentation (more to come...)
- CHANGED: Disabled Sendfile [mitchellh/vagrant#351 (comment)](https://github.com/mitchellh/vagrant/issues/351#issuecomment-1339640)
- FIXED: Broken MySQL build script
- CHANGED: Restructured source files and development workflow
- FIXED: PROJECT_ROOT variable used by `user_setup`
- FIXED: Broken package source URLs
- CHANGED: Enabled and loaded shared Apache modules

## 0.1.0

Initial release
