#!/usr/bin/env ruby
require 'yaml'

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
    puts "Dreambox config file: #{vm_config_file_path}"
  else
    abort("Config file '#{vm_config_file_path}' not found.\n >> See 'Getting Started': https://github.com/goodguyry/dreambox/wiki")
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

  # Set default 'box' values
  defaults = Hash.new
  defaults['name'] = 'dreambox'
  defaults['php_version'] = '5'

  # Merge the default 'box' values with those from vm-config
  VM_CONFIG['box'] = defaults.merge(VM_CONFIG['box'])

  # We only need the first character of the PHP version value
  # This should end up being '5' or '7'
  VM_CONFIG['box']['php_version'] = VM_CONFIG['box']['php'][0,1]

  # Test the PHP version and set the PHP directory
  # Abort of the value isn't one of the two specific options
  if '5' === VM_CONFIG['box']['php_version'] then
    VM_CONFIG['box']['php_dir'] = 'php56'
  elsif '7' === VM_CONFIG['box']['php_version'] then
    VM_CONFIG['box']['php_dir'] = 'php70'
  else
    abort("Invalid `php` value in #{vm_config_file_path}\n >> Should be either \'5\' or \'7\'.")
  end
end
