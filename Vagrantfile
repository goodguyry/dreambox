# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_ARGS = ARGV

# config_file = 'vm-config.yml-example'

# Shoehorn the config file into our test Vagrantfile
require_relative File.join(File.expand_path(Dir.pwd), 'templates/class_config.rb')

dreambox_config_file = (defined?(config_file)) ? config_file : 'vm-config.yml'
dns_hosts_file = File.join(File.expand_path(Dir.pwd), 'templates/dns_hosts.txt')

Dreambox = Config.new(dreambox_config_file, dns_hosts_file)

Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise64"
  config.vm.box_url = "https://atlas.hashicorp.com/hashicorp/boxes/precise64"

  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # Set these so the provisioning scripts can be run via ssh
  file_dirs = {
    'files' => '/tmp/files',
    'scripts' => '/tmp/scripts',
    'packages' => '/tmp/packages' ,
  }

  file_dirs.each do | dir, path |
    config.vm.synced_folder "#{dir}", "#{path}",
    create: false,
    :mount_options => ['dmode=775,fmode=664']
  end

  # REVIEW See synced_folder line
  # $user_vars["DREAMBOX_UID"] = 31415

  # REVIEW We're going to listen for a user _after_ `ssh` instead
  # REVIEW We need to check for multimachine so shit doesn't break
  # if 'ssh' == VAGRANT_ARGS.first && VAGRANT_ARGS.length == 3
  #   config.ssh.username = VAGRANT_ARGS[1] if config.vm.defined_vm_keys.length == 1
  # end

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
    test.vm.provision "Base",
      type: "shell",
      path: "scripts/base.sh"

    # Post-install MySQL setup
    test.vm.provision "Package Setup",
      type: "shell",
      path: "scripts/package-setup.sh"

    # Install PHP
    test.vm.provision "PHP Install",
      type: "shell",
      path: "files/php_install",
      :env => Dreambox.config

    if Dreambox.config['ssl_enabled'] then
      test.vm.provision "SSL Setup",
        type: "shell",
        path: "scripts/ssl.sh",
        :env => Dreambox.config
    end

    # TODO Change this to .each_value
    Dreambox.config['sites'].each do |site, conf|
      # Runs user_setup
      test.vm.provision "User Setup: #{conf['username']}",
        type: "shell",
        path: "scripts/user.sh",
        :env => conf

      if (! conf['is_subdomain']) then
        # Sets up the sync folder
        test.vm.synced_folder conf['local_root'], conf['root_path'],
          owner: "#{conf['uid']}",
          group: "#{conf['gid']}",
          mount_options: ["dmode=775,fmode=664"]
      end

      # Runs user_setup
      test.vm.provision "VHost Setup: #{conf['host']}",
        type: "shell",
        path: "scripts/vhost.sh",
        :env => conf
    end
  end
end
