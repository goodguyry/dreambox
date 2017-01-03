# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.box_url = "https://atlas.hashicorp.com/hashicorp/boxes/precise64"

  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # Set these so the provisioning scripts can be run via ssh
  config.vm.synced_folder "files", "/tmp/files", create: false, :mount_options => ["dmode=775", "fmode=664"]
  config.vm.synced_folder "packages", "/tmp/packages", create: false, :mount_options => ["dmode=775", "fmode=664"]

  # Development machine
  # Ubuntu 12.04
  config.vm.define 'dev' do |dev|
    dev.vm.hostname = "dreambox.dev"
    dev.vm.network :private_network, ip: "192.168.12.34"
  end

  # Testing machine
  # Fully provisioned and ready to test
  config.vm.define 'test' do |test|
    test.vm.hostname = "dreambox.test"
    test.vm.network :private_network, ip: "192.168.56.78"

    # Sets up the sync folder
    test.vm.synced_folder 'web', '/home/db_user/dreambox.test'

    # Start bash as a non-login shell
    test.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    # Installed utinities and libraries
    test.vm.provision "base",
      type: "shell",
      path: "scripts/base.sh",
      # Environment variable for simulating Packer file provisioner
      :env => {"DREAMBOX_ENV" => "develop"}

    # Post-install MySQL setup
    test.vm.provision "package-setup",
      type: "shell",
      path: "scripts/package-setup.sh"

    # Environment variables for automating user_setup
    user_vars = {
      "DREAMBOX_USER_NAME" => "db_user",
      "DREAMBOX_SITE_ROOT" => "dreambox.test",
      "DREAMBOX_PROJECT_DIR" => "web",
      "ENABLE_SSL" => true
    }

    # Runs user_setup
    test.vm.provision "shell",
      inline: "/bin/bash /usr/local/bin/user_setup",
      # Pass user_setup ENV variables to this script
      :env => user_vars
  end
end
