# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

vagrant_dir = File.expand_path(File.dirname(__FILE__))

if defined? vm_config_file
  vm_config_file_path = File.join(vagrant_dir, vm_config_file)
else
  vm_config_file_path = File.join(vagrant_dir, 'vm-config.yml')
end

if File.file?(vm_config_file_path) then
  vm_config = YAML.load_file(vm_config_file_path)
end

vm_config['sites'].each do |site, items|
  if ! items.kind_of? Hash then
      items = Hash.new
  end

  defaults = Hash.new
  defaults['local_root'] = 'web'
  defaults['ssl_enabled'] = false

  items['root_path'] = "/home/#{items['username']}/#{items['web_root']}"

  items['config'].each do |conf|
    case conf
    when 'ssl'
      items['ssl_enabled'] = true
      items['ssl_name'] = items['host']
    end
  end

  vm_config['sites'][site].delete('config')
  vm_config['sites'][site] = defaults.merge(items)
end

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
  config.vm.define 'dev', autostart: false do |dev|
    dev.vm.hostname = "dreambox.dev"
    dev.vm.network :private_network, ip: "192.168.12.34"
  end

  # Testing machine
  # Fully provisioned and ready to test
  config.vm.define 'test', primary: true do |test|
    test.vm.hostname = "dreambox.test"
    test.vm.network :private_network, ip: "192.168.56.78"


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

    vm_config['sites'].each do |site, conf|
      # Sets up the sync folder
      test.vm.synced_folder conf['local_root'], conf['root_path']
      # Runs user_setup
      test.vm.provision "shell",
        inline: "/bin/bash /usr/local/bin/user_setup",
        # Pass user_setup ENV variables to this script
        :env => {
          "DREAMBOX_USER_NAME"    => conf['username'],
          "DREAMBOX_SITE_ROOT"    => conf['web_root'],
          "DREAMBOX_PROJECT_DIR"  => conf['local_root'],
          "DREAMBOX_HOST"         => conf['host'],
          "ENABLE_SSL"            => conf['ssl_enabled'],
          "DREAMBOX_SITE_NAME"    => conf['ssl_name'],
        }
    end
  end
end
