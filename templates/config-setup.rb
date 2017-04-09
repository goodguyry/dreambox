#!/usr/bin/env ruby
require 'yaml'

class String
  def red;     "\e[31m#{self}\e[0m" end
  def green;   "\e[32m#{self}\e[0m" end
  def yellow;  "\e[33m#{self}\e[0m" end
  def bold;    "\e[1m#{self}\e[22m" end
end

module Config
  vagrant_dir = File.expand_path(Dir.pwd)

  # Build the config filepath
  if defined? vm_config_file
    vm_config_file_path = File.join(vagrant_dir, vm_config_file)
  else
    vm_config_file_path = File.join(vagrant_dir, 'vm-config.yml')
  end

  # Load the config file if found
  # Otherwise abort with message
  if File.file?(vm_config_file_path) then
    VM_CONFIG = YAML.load_file(vm_config_file_path)
  else
    puts "Config file '#{vm_config_file_path}' not found.".bold.red
    abort "===> See 'Getting Started': https://github.com/goodguyry/dreambox/wiki".bold.yellow
  end

  VM_CONFIG['hosts'] = Array.new
  VM_CONFIG['ssl_enabled'] = false

  # Collect settings for each site
  VM_CONFIG['sites'].each do |site, items|
    if ! items.kind_of? Hash then
      items = Hash.new
    end

    # Establish defaults
    defaults = Hash.new
    defaults['local_root'] = 'web'

    # Build paths here rather than in a provisioner
    items['root_path'] = "/home/#{items['username']}/#{items['web_root']}"
    items['vhost_file'] = "/usr/local/apache2/conf/vhosts/#{items['hosts'][0]}.conf"

    # Temporary fix
    if ! items['hosts'].kind_of? Array then
      items['host'] = items['hosts'][0]
    end

    # Take hosts and create a large string in a root 'hosts' property
    # just push it, since it doesn't matter what type it is
    if (items['ssl'] || VM_CONFIG['box']['ssl']) then
      VM_CONFIG['ssl_enabled'] = true
      VM_CONFIG['hosts'] = VM_CONFIG['hosts'].push(*items['hosts'])
    end

    # Delete properties we no longer need
    VM_CONFIG['sites'][site].delete('hosts')
    VM_CONFIG['sites'][site].delete('ssl')

    # Merge in settings
    VM_CONFIG['sites'][site] = defaults.merge(items)
  end

  # Merge hosts into string in a root 'hosts' property
  VM_CONFIG['hosts'] = VM_CONFIG['hosts'].join(',')

  # Allowed php values
  php_versions = ['5', '7']
  php_dirs = ['php56', 'php70']

  # Set default 'box' values
  box_defaults = Hash.new
  box_defaults['name'] = 'dreambox'
  box_defaults['php'] = php_versions[0]

  # Merge the default 'box' values with those from vm-config
  VM_CONFIG['box'] = box_defaults.merge(VM_CONFIG['box'])

  # Abort of the php version isn't one of the two specific options
  if ! php_versions.include?(VM_CONFIG['box']['php']) then
    abort "===> Dreambox config: Acceptable `php` values are '#{php_versions[0]}' and '#{php_versions[1]}'".bold.red
  end

  # Test the PHP version and set the PHP directory
  VM_CONFIG['box']['php_dir'] = php_versions[0] === VM_CONFIG['box']['php'] ? php_dirs[0] : php_dirs[1]

  if VM_CONFIG['debug'] then
    puts "Dreambox Debug:".bold.yellow
    puts "===> Config File:   #{vm_config_file_path}".bold
    puts "===> Box Name:      #{VM_CONFIG['box']['name']}".bold
    puts "===> PHP Version:   #{VM_CONFIG['box']['php']}".bold
    puts "===> SSL Enabled:   #{VM_CONFIG['ssl_enabled']}".bold
    puts "===> Hosts:         #{VM_CONFIG['hosts']}".bold
    puts ''
    VM_CONFIG['sites'].each do |site, items|
      puts "===> #{site}['local_root']   #{items['local_root']}".bold
      puts "===> #{site}['root_path']    #{items['root_path']}".bold
      puts ''
    end
    puts ''
  end
end
