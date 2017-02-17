#!/usr/bin/env ruby
require 'yaml'

module Config
  vagrant_dir = File.expand_path(Dir.pwd)

  if defined? vm_config_file
    vm_config_file_path = File.join(vagrant_dir, vm_config_file)
  else
    vm_config_file_path = File.join(vagrant_dir, 'vm-config.yml')
  end

  if File.file?(vm_config_file_path) then
    VM_CONFIG = YAML.load_file(vm_config_file_path)
  else
    # Error feedback
    abort("Config file '#{vm_config_file_path}' not found.\n >> See 'Getting Started': https://github.com/goodguyry/dreambox/wiki")
  end

  puts "Dreambox config file: #{vm_config_file_path}"

  VM_CONFIG['sites'].each do |site, items|
    if ! items.kind_of? Hash then
        items = Hash.new
    end

    defaults = Hash.new
    defaults['local_root'] = 'web'
    defaults['ssl_enabled'] = false

    items['root_path'] = "/home/#{items['username']}/#{items['web_root']}"

    if ! items['config'].kind_of? Array then
        items['config'] = Array.new
    end

    items['config'].each do |conf|
      case conf
      when 'ssl'
        items['ssl_enabled'] = true
        items['ssl_name'] = items['host']
      end
    end

    VM_CONFIG['sites'][site].delete('config')
    VM_CONFIG['sites'][site] = defaults.merge(items)
  end

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
  if '5' === VM_CONFIG['box']['php_version'] then
    VM_CONFIG['box']['php_dir'] = 'php56'
  elsif '7' === VM_CONFIG['box']['php_version'] then
    VM_CONFIG['box']['php_dir'] = 'php70'
  else
    # Error feedback
    abort("Invalid `php` value in #{vm_config_file_path}\n >> Should be either \'5\' or \'7\'.")
  end
end
