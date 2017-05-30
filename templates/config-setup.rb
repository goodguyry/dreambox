#!/usr/bin/env ruby
require 'yaml'
require_relative 'config-utilities.rb'

module Config
  vm_config_file = $vm_config_file || 'vm-config.yml'
  vagrant_dir = File.expand_path(Dir.pwd)

  # Build the config filepath
  if (defined?(vm_config_file)) && (vm_config_file.kind_of? String) then
    vm_config_file_path = File.join(vagrant_dir, vm_config_file)
  else
    print_error("There was an error with `$vm_config_file` declaration: '#{vm_config_file}'", true)
  end

  # Load the config file if found
  # Otherwise abort with message
  if File.file?(vm_config_file_path) then
    VM_CONFIG = YAML.load_file(vm_config_file_path)
  else
    print_error("Config file '#{vm_config_file_path}' not found.", true)
  end

  # Set config defaults
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
  box_defaults.merge(VM_CONFIG)

  # Abort of the php version isn't one of the two specific options
  if ! php_versions.include?(VM_CONFIG['php']) then
    print_error("Accepted `php` values are '#{php_versions[0]}' and '#{php_versions[1]}'", true)
  end

  # Set the PHP directory
  VM_CONFIG['php_dir'] = php_dirs[php_versions.index(VM_CONFIG['php'])]

  subdomains = Hash.new

  VM_CONFIG['sites'].each do |site, items|
    if ! items.kind_of? Hash then
      items = Hash.new
    end

    # Check for required site properties before proceeding
    required = ['username', 'root', 'local_root', 'host']
    required.each do |property|
      if ! (items[property].kind_of? String) then
        print_error("Missing #{property} for site #{site}.", true)
      else
        items[property] = trim_slashes(items[property])
      end
    end

    # Establish site defaults
    defaults = Hash.new
    defaults['box_name'] = VM_CONFIG['name']
    defaults['is_subdomain'] = false

    # Add the site's `host` to the root 'hosts' property
    if items['host'].kind_of? String then
      # De-dup hosts values
      if ! VM_CONFIG['hosts'].include?(items['host']) then
        VM_CONFIG['hosts'] = VM_CONFIG['hosts'].push(*items['host'])
      end
    else
      print_error("Invalid `host` value for site '#{site}'.", true)
    end

    # Build paths here rather than in a provisioner
    path_end = (items['public'].kind_of? String) ? File.join(items['root'], trim_slashes(items['public'])) : items['root']
    items['root_path'] = File.join('/home/', items['username'], path_end)
    items['vhost_file'] = File.join('/usr/local/apache2/conf/vhosts/', "#{site}.conf")

    # Add each of the site's hosts to the root 'hosts' property
    # Also combine aliases into a space-separated string
    if (items['aliases'].kind_of? Array) then
      if items['aliases'].length then
        items['aliases'].each do |the_alias|
          # De-dup hosts values
          if ! VM_CONFIG['hosts'].include?(the_alias) then
            VM_CONFIG['hosts'] = VM_CONFIG['hosts'].push(*the_alias)
          end
        end
        items['aliases'] = items['aliases'].join(' ')
      else
        print_error("Expected `aliases` value to be an Array for site '#{site}'.", true)
      end
    end

    # If SSL is enabled globally and not disabled locally, or if enabled locally
    if (VM_CONFIG['ssl'] && (false != items['ssl'] || ! defined?(items['ssl']))) || items['ssl'] then
      # Enable the root SSL setting if not already enabled
      VM_CONFIG['ssl_enabled'] = true
      # Ensure the site SSL setting is enabled
      # If it's enabled globally, but not at the site, ssl_setup will fail
      items['ssl'] = true
    end

    # Collect and merge site subdomains
    # Each subdomain is transformed into it's own site, based on the parent site's config values
    if (items['subdomains'].kind_of? Hash) then
      items['subdomains'].each do |sub, path|
        subdomain_name = "#{sub}.#{site}"
        subdomains[subdomain_name] = {
          'username' => items['username'],
          'root_path' => File.join(items['root_path'], trim_slashes(path)),
          'is_subdomain' => true,
          'vhost_file' => File.join('/usr/local/apache2/conf/vhosts/', "#{subdomain_name}.conf"),
          'host' => "#{sub}.#{('www' == items['host'][0..2]) ? items['host'][4..-1] : items['host']}",
          'ssl' => items['ssl'],
          'box_name' => VM_CONFIG['name']
        }
        # De-dup and add to root hosts property
        if ! VM_CONFIG['hosts'].include?(subdomains[subdomain_name]['host']) then
          VM_CONFIG['hosts'] = VM_CONFIG['hosts'].push(*subdomains[subdomain_name]['host'])
        end
      end
    end

    # Merge in settings
    VM_CONFIG['sites'][site] = defaults.merge(items)
  end

  # Merge subdomain sites into `sites` hash
  # Done here to avoid unexpected looping /shrug
  VM_CONFIG['sites'] = VM_CONFIG['sites'].merge(subdomains)

  # Collect and transform host values
  if VM_CONFIG['hosts'].length then
    # Save the first `hosts` index if no root `host` is declared
    if (! VM_CONFIG['host'].kind_of? String) then
      VM_CONFIG['host'] = VM_CONFIG['hosts'][0]
    end
    # Build a DNS host file to `cat` into SSL config
    dns_hosts = File.join(File.dirname(__FILE__), 'dns-hosts.txt')
    if File.exist?(dns_hosts) then
      File.delete(dns_hosts)
    end
    VM_CONFIG['hosts'].each.with_index(1) do |host, index|
      File.open(dns_hosts, 'a+') { |file| file.puts("DNS.#{index} = #{host}") }
    end
    # Merge the root `hosts` property into a comma-separated string
    VM_CONFIG['hosts'] = VM_CONFIG['hosts'].join(',')
  else
    # If no hosts, force disable SSL at the root and all sites
    VM_CONFIG['ssl_enabled'] = false
    VM_CONFIG['sites'].each do |site, items|
      items['ssl'] = false
    end
    print_error("Missing hosts list; SSL disabled.", false)
  end

  # Print debug information
  if VM_CONFIG['debug'] then
    print_debug_info(VM_CONFIG, vm_config_file_path)
  end
end
