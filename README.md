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

Initialize a new project using this box by running the following commands:

```shell
vagrant init goodguyry/dreambox
vagrant up
```

To use this box with an existing project, use the following in your Vagrantfile:

```ruby
config.vm.box = "goodguyry/dreambox"
config.vm.box_url = "https://atlas.hashicorp.com/goodguyry/boxes/dreambox"
```

### User Setup

DreamBox is meant to replicate both the hosting environment _and_ the shared hosting setup (the full path to the web root). The `user_setup` script is provided to create the user directory and link the project root in your Vagrant sync folder to your new web root.

The `user_setup` script should be automated as part of your provisioning. Pass environment variables to the provisioner as follows, changing the variable values to reflect your needs.

```ruby
  # Environment variables for automating user_setup
  user_vars = {
    "DREAMBOX_USER_NAME" => "db_user", # DreamHost username
    "DREAMBOX_SITE_ROOT" => "dreambox.com", # Site root directory
    "DREAMBOX_PROJECT_DIR" => "/web" # Relative to project root
  }

  # Runs user_setup
  config.vm.provision "shell",
    inline: "/bin/bash /usr/local/bin/user_setup",
    # Pass user_setup ENV variables to this script
    :env => user_vars

```

Alternatively, if you'd rather not commit this information to a public repo, run `user_setup` from within the VM and follow the prompts.

```shell
vagrant up
vagrant ssh
sudo user_setup
```

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

### v0.1.0

Initial release, based on https://github.com/goodguyry/dreambox
