# -*- mode: ruby -*-
# vi: set ft=ruby :

# Shoehorn the config file into our test Vagrantfile
require_relative File.join(File.expand_path(Dir.pwd), 'templates/class_config.rb')

# config_file = 'vm-config.yml-example'
dreambox_config_file = (defined?(config_file)) ? config_file : 'vm-config.yml'

Dreambox = Config.new(dreambox_config_file)

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.box_url = "https://atlas.hashicorp.com/hashicorp/boxes/trusty64"

  config.vm.network :forwarded_port, guest: 80, host: 8080, auto_correct: true

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  # Development machine
  # Ubuntu 14.04
  config.vm.define 'dev', autostart: false do |dev|
    dev.vm.hostname = "dreambox.dev"
    dev.vm.network :private_network, ip: "192.168.12.34"

    # Recreates the Packer file provisioner
    config.vm.provision "file", source: "files", destination: "/tmp/files"
  end

  # Testing machine
  # To be fully provisioned and ready to test
  config.vm.define 'test', primary: true do |test|
    test.vm.hostname = "dreambox.test"
    test.vm.network :private_network, ip: "192.168.56.78"

    # Recreates the Packer file provisioner
    files = {
      'files' => '/tmp/files',
      'packages' => '/tmp/packages',
      'provisioners' => '/tmp/provisioners',
    }
    files.each { | dir, path | config.vm.provision "file", source: "#{dir}", destination: "#{path}" }

    # Start bash as a non-login shell
    test.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

    test.vm.provision "Base",
      type: "shell",
      path: "provisioners/base.sh"

    test.vm.provision "Package Setup",
      type: "shell",
      path: "provisioners/package-setup.sh"

    test.vm.provision "PHP Install",
      type: "shell",
      path: "provisioners/php.sh",
      :env => Dreambox.config

    if Dreambox.config['ssl_enabled'] then
      test.vm.provision "SSL Setup",
        type: "shell",
        path: "provisioners/ssl.sh",
        :env => Dreambox.config
    end

    Dreambox.config['sites'].each do |site, conf|
      test.vm.provision "User Setup: #{conf['user']}",
        type: "shell",
        path: "provisioners/user.sh",
        :env => conf

      if (! conf['is_subdomain']) then
        test.vm.synced_folder conf['local_root'], conf['root_path'],
          owner: "#{conf['uid']}",
          group: "#{conf['gid']}",
          mount_options: ["dmode=775,fmode=664"]
      end

      test.vm.provision "VHost Setup: #{conf['host']}",
        type: "shell",
        path: "provisioners/vhost.sh",
        :env => conf
    end
  end
end
