# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.box_url = "https://atlas.hashicorp.com/hashicorp/boxes/precise64"

  config.vm.network :forwarded_port, guest: 98, host: 9898, auto_correct: true

  config.vm.synced_folder "web", "/vagrant/web", create: true, owner: "www-data", group: "www-data"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--name", "dreambox"]
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # Start bash as a non-login shell
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Installed utinities and libraries
  config.vm.provision "base",
    type: "shell",
    path: "scripts/base.sh",
    # Environment variable for simulating Packer file provisioner
    :env => {"DREAMBOX_ENV" => "develop"}

  # Post-install MySQL setup
  config.vm.provision "package-setup",
    type: "shell",
    path: "scripts/package-setup.sh"

  # Environment variables for automating user_setup
  user_vars = {
    "DREAMBOX_USER_NAME" => "db_user",
    "DREAMBOX_SITE_ROOT" => "dreambox.com",
    "DREAMBOX_PROJECT_DIR" => "web"
  }

  # Runs user_setup
  config.vm.provision "shell",
    inline: "/bin/bash /usr/local/bin/user_setup",
    # Pass user_setup ENV variables to this script
    :env => user_vars

  config.vm.define 'dreambox' do |node|
    node.vm.hostname = "dreambox.dev"
    node.vm.network :private_network, ip: "192.168.12.34"
  end
end
