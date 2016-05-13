Building Dreambox
=================

For information about using Dreambox in your project, see the [usage instructions](https://github.com/goodguyry/dreambox/blob/master/README.md#usage).

## Packer test build

Building with [Packer](https://www.packer.io/) will build a more accurate box, but takes quite a bit longer. If you don't already have Packer installed, you can install it via [Homebrew](http://brew.sh/) by running `brew install packer`

```shell
# From the dreambox project root
./build
```

The `build` script will build the box locally and add it to Vagrant so you can then test with an existing project.

```ruby
config.vm.box = "dreambox_pre"
```

## Vagrant

This project makes use of [Vagrant's Multi-Machine feature](https://www.vagrantup.com/docs/multi-machine/).

### Test build

Build the `test` machine to test the provisioner, added features, etc. This builds a production-ready version of Dreambox for testing updates.

```shell
# To create the test box
vagrant up test
# To SSH into the test box
vagrant ssh test
```

**host**: [dreambox.test](http://dreambox.test)

### Development build

Build the `dev` machine to install or troubleshoot new software installations. This box builds a base Ubuntu 12.04 box with no packages installed. See the `src` directory for examples compile scripts when adding new software.

```shell
# To create the development box
vagrant up dev
# To SSH into the development box
vagrant ssh dev
```

**host**: [dreambox.dev](http://dreambox.dev)
