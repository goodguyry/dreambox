#!/usr/bin/env ruby
require 'yaml'

class String
  def red;     "\e[31m#{self}\e[0m" end
  def green;   "\e[32m#{self}\e[0m" end
  def yellow;  "\e[33m#{self}\e[0m" end
  def bold;    "\e[1m#{self}\e[22m" end
end

def print_error(message)
   puts "===> Dreambox config: #{message}".bold.red
   abort "     See 'Getting Started': https://github.com/goodguyry/dreambox/wiki".bold.yellow
end

module Config
  vagrant_dir = File.expand_path(Dir.pwd)

  # Build the config filepath
  if defined?(vm_config_file)
    vm_config_file_path = File.join(vagrant_dir, vm_config_file)
  else
    vm_config_file_path = File.join(vagrant_dir, 'vm-config.yml')
  end

  # Load the config file if found
  # Otherwise abort with message
  if File.file?(vm_config_file_path) then
    VM_CONFIG = YAML.load_file(vm_config_file_path)
  else
    print_error "Config file '#{vm_config_file_path}' not found."
  end

  VM_CONFIG['hosts'] = Array.new
  VM_CONFIG['ssl_enabled'] = false

  # Collect settings for each site
  # Allowed php values
  php_versions = ['5', '7']
  php_dirs = ['php56', 'php70']

  # Set default 'box' values
  box_defaults = Hash.new
  box_defaults['name'] = 'dreambox'
  box_defaults['php'] = php_versions[0]

  # Merge the default 'box' values with those from vm-config
  # VM_CONFIG = box_defaults.merge(VM_CONFIG)
  box_defaults.merge(VM_CONFIG)

  # Abort of the php version isn't one of the two specific options
  if ! php_versions.include?(VM_CONFIG['php']) then
    print_error "Accepted `php` values are '#{php_versions[0]}' and '#{php_versions[1]}'"
  end

  # Test the PHP version and set the PHP directory
  VM_CONFIG['php_dir'] = php_versions[0] === VM_CONFIG['php'] ? php_dirs[0] : php_dirs[1]

  VM_CONFIG['sites'].each do |site, items|
    if ! items.kind_of? Hash then
      items = Hash.new
    end

    # Establish site defaults
    defaults = Hash.new
    defaults['local_root'] = 'www'
    defaults['box_name'] = VM_CONFIG['name']

    # Set the site host value
    if ! defined?(items['host']) || ! (items['host'].kind_of? String) then
      if (items['hosts'].kind_of? Array) && 0 < items['hosts'].length then
        # Add first `hosts` value for the `host` property
        items['host'] = items['hosts'][0]
      else
        print_error "Missing `host` and/or `hosts` values."
      end
    end

    # Build paths here rather than in a provisioner
    items['root_path'] = "/home/#{items['username']}/#{items['web_root']}"
    items['vhost_file'] = "/usr/local/apache2/conf/vhosts/#{items['host']}.conf"

    # If SSL is enabled globally and not disabled locally, or if enabled locally
    if (VM_CONFIG['ssl'] && (false != items['ssl'] || ! defined?(items['ssl']))) || items['ssl'] then
      # Enable the root SSL setting if not already enabled
      VM_CONFIG['ssl_enabled'] = true
      # Ensure the site SSL setting is enabled
      # If it's enabled globally, but not at the site, ssl_setup will fail
      items['ssl'] = true
      # Add the site's main host to the root `hosts` property
      if defined?(items['host']) then
        VM_CONFIG['hosts'] = VM_CONFIG['hosts'].push(*items['host'])
      end
      # Add each of the site's hosts to the root 'hosts' property
      if items['hosts'].kind_of? Array then
        items['hosts'].each do |host|
          # De-dup hosts values
          if ! VM_CONFIG['hosts'].include?(host) then
            VM_CONFIG['hosts'] = VM_CONFIG['hosts'].push(*host)
          end
        end
      end
    end

    # Delete properties we no longer need
    VM_CONFIG['sites'][site].delete('hosts')

    # Merge in settings
    VM_CONFIG['sites'][site] = defaults.merge(items)
  end

  # Merge hosts into string in a root 'hosts' property
  VM_CONFIG['hosts'] = VM_CONFIG['hosts'].join(',')

  # One last check to make sure we have hosts
  # If not, force disable SSL
  if 1 > VM_CONFIG['hosts'].length then
    VM_CONFIG['ssl_enabled'] = false
    puts "===> Dreambox config: Missing hosts list; SSL disabled.".bold.yellow
  end

  if VM_CONFIG['debug'] then
    puts ''
    puts "===> Dreambox Debug:".bold.yellow
    puts "     Config File:   #{vm_config_file_path}".bold
    puts "     Box Name:      #{VM_CONFIG['name']}".bold
    puts "     PHP Version:   #{VM_CONFIG['php']}".bold
    puts "     SSL Enabled:   #{VM_CONFIG['ssl_enabled']}".bold
    if 0 < "#{VM_CONFIG['hosts']}".length then
      puts "     Hosts:         #{VM_CONFIG['hosts']}".bold
    end
    puts ''
    VM_CONFIG['sites'].each do |site, items|
      puts "===> #{site}: username     #{items['username']}".bold
      puts "     #{site}: root_path    #{items['root_path']}".bold
      puts "     #{site}: web_root     #{items['web_root']}".bold
      puts "     #{site}: local_root   #{items['local_root']}".bold
      if 0 < "#{items['ssl']}".length then
        puts "     #{site}: ssl          #{items['ssl']}".bold
      end
      puts "     #{site}: box_name     #{items['box_name']}".bold
      puts "     #{site}: host         #{items['host']}".bold
      puts ''
    end
    puts ''
  end
end
