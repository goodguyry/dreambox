DreamBox
========

> Recreates the DreamHost shared hosting environment as a Vagrant box.

This project repo is for [building the Dreambox base box](BUILDING.md). To use this box in a project, see [the usage instructions](#usage) below.

## Features

- Ubuntu - `12.04 LTS`
- PHP - `5.6.10`
- Apache - `2.2.22` (CGI/FastCGI)
- MySQL - `5.5.40`

_Python and Ruby environments are not set up. [Contributions](CONTRIBUTING.md) are welcome and appreciated._

## Usage

### Vagrantfile setup

Choose one of the following methods for getting started with Dreambox:

Pull [the example Vagrantfile](Vagrantfile-example) into your project directory...

```shell
curl https://raw.githubusercontent.com/goodguyry/dreambox/master/Vagrantfile-example > Vagrantfile
```

**- or -** use this box with an existing project by adding the following to your Vagrantfile...

```ruby
config.vm.box = "goodguyry/dreambox"
```

**- or -** initialize a new project using this box by running the following command:

```shell
vagrant init goodguyry/dreambox
```

### User Setup

DreamBox is meant to replicate both the hosting environment _and_ the shared hosting setup (the full path to the web root).

A user setup script is _automatically run_ by Dreambox during `vagrant up`. The following Hash must be in your Vagrantfile for Dreambox to provision correctly:

```ruby
  # Environment variables for automating user_setup
  $user_vars = {
    'DREAMBOX_USER_NAME' => 'my-user',      # DreamHost username
    'DREAMBOX_SITE_ROOT' => 'example.com',  # Site root directory
    'DREAMBOX_PROJECT_DIR' => 'web'         # Relative to project root
  }
```

See [the example Vagrantfile](Vagrantfile-example) for a basic Dreambox Vagrantfile setup.

### MySQL Setup (Optional)

To set a password for the root mysql user, run `mysql_secure_installation` from within the VM.

```shell
vagrant up
vagrant ssh
mysql_secure_installation
```

## References

- http://phpinfo.dreamhosters.com/ (outdated)
- http://wiki.dreamhost.com/Supported_and_unsupported_technologies

## Changelog

### v0.1.1

- Added a Dreambox Message of the Day (motd)
- Fixed an issue preventing sites from displaying when accessed via IP address
- Added compiled package files
- Cleaned up documentation (more to come...)
- Disabled Sendfile [mitchellh/vagrant#351 (comment)](https://github.com/mitchellh/vagrant/issues/351#issuecomment-1339640)
- Fixed broken MySQL build script
- Restructured source files and development workflow
- Fixed PROJECT_ROOT variable used by `user_setup`
- Updated broken package source URLs
- Enabled and loaded shared Apache modules

### v0.1.0

Initial release
