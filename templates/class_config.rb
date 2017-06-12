#!/usr/bin/env ruby

require 'yaml'
require_relative 'utilities.rb'

# Config class
#
# The Config class collects and transforms the config file's values to prepare them
# for the Dreambox provisioning scripts.
class Config
  attr_accessor :config
  attr_reader :raw

  # Helper functions for manipulating Strings
  def trim_ending_slash(str)
    return ('/' == str[-1..-1]) ? str[0..-2] : str
  end

  def trim_beginning_slash(str)
    return ('/' == str[0..0]) ? str[1..-1] : str
  end

  def trim_slashes(str)
    return trim_ending_slash(trim_beginning_slash(str))
  end

  def sanitize_alias(host)
    return ('*.' == host[0..1]) ? host[2..-1] : host
  end

  # De-dup and add site host to root hosts array
  def add_host(host)
    if ! @config.fetch('hosts').include?(host) then
      @config['hosts'] = @config.fetch('hosts').push(host)
    end
  end

  def remove_www(host)
    return ('www' == host[0..2]) ? host[4..-1] : host
  end

  # Class initialization
  #
  # This method does all the heavy lifting
  #
  # @param String {config_file} The path to the config file
  # @param String {hosts_file} The location at which to create the DNS Hosts file
  def initialize(config_file, hosts_file)
    @config_file = config_file
    @hosts_file = hosts_file

    vagrant_dir = File.expand_path(Dir.pwd)

    # Build the config filepath
    if (defined?(@config_file)) && (@config_file.kind_of? String) then
      @vm_config_file_path = File.join(vagrant_dir, @config_file)
    else
      print_error("There was an error with `config_file` declaration: '#{@config_file}'", true)
    end

    # Load the config file if found, otherwise abort
    if File.file?(@vm_config_file_path) then
      @raw = YAML.load_file(@vm_config_file_path)
    else
      print_error("Config file '#{@vm_config_file_path}' not found.", true)
    end

    # Allowed PHP values
    php_versions = ['5', '7']
    # Associated PHP install directories
    php_dirs = ['php56', 'php70']

    # Set config defaults
    box_defaults = {}
    box_defaults['name'] = 'dreambox'
    box_defaults['php'] = php_versions.first
    box_defaults['ssl'] = false
    box_defaults['hosts'] = []
    box_defaults['ssl_enabled'] = false

    # Merge the default 'box' values with those from vm-config
    @config = box_defaults.merge(@raw)

    # Abort of the php version isn't one of the two specific options
    if ! php_versions.include?(@config.fetch('php')) then
      print_error("Accepted `php` values are '#{php_versions.first}' and '#{php_versions.last}'", true)
    end

    # Set the PHP directory
    @config['php_dir'] = php_dirs[php_versions.index(@config.fetch('php'))]

    # To collect subdomains
    # These will be transformed into sites at the end
    subdomains = {}

    # Collect settings for each site
    @config['sites'].each_key do |site|
      items = @config['sites'].fetch(site)

      if ! items.kind_of? Hash then
        items = {}
      end

      # Check for required site properties before proceeding
      # If found, remove any errant slashes
      # We allow slashes in the config file to increase readability
      required = ['username', 'root', 'local_root', 'host']
      required.each do |property|
        if (items.fetch(property).kind_of? String) then
          items[property] = trim_slashes(items.fetch(property))
        else
          print_error("Missing #{property} for site #{site}.", true)
        end
      end

      # Inherit the SSL property if it's not set
      if ! items.key?('ssl') then
        items['ssl'] = @config.fetch('ssl')
      end

      # If SSL is enabled globally and not disabled locally, or if enabled locally
      if (@config.fetch('ssl') && false != items.fetch('ssl')) || items.fetch('ssl') then
        collect_hosts = true
        # Enable the root SSL setting if not already enabled
        @config['ssl_enabled'] = true
      end

      # Establish site defaults
      defaults = {}
      defaults['box_name'] = @config.fetch('name')
      defaults['is_subdomain'] = false

      # Build paths here rather than in a provisioner
      root_path = File.join('/home/', items.fetch('username'), items.fetch('root'))

      # Account for a `public` folder if set
      items['root_path'] = (items.key?('public')) ?
        File.join(root_path, trim_slashes(items.fetch('public'))) : root_path
      items['vhost_file'] = File.join('/usr/local/apache2/conf/vhosts/', "#{site}.conf")

      # We only collect host values if SSL is enabled
      if collect_hosts then
        if ! @config.key?('host') then
          @config['host'] = items.fetch('host')
        else
          add_host(items.fetch('host'))
        end
      end

      # Add each of the site's hosts to the root [hosts] property
      if (items['aliases'].kind_of? Array) then
        if items['aliases'].length then
          if collect_hosts then
            items['aliases'].each do |the_alias|
              add_host(sanitize_alias(the_alias))
            end
          end
          # Combine `aliases` into a space-separated string
          items['aliases'] = items.fetch('aliases').join(' ')
        else
          print_error("Expected `aliases` value to be an Array for site '#{site}'.", true)
        end
      end

      # Collect and merge site subdomains
      # Each subdomain is transformed into it's own site, based on the parent site's config values
      if (items['subdomains'].kind_of? Hash) then
        items['subdomains'].each_key do |sub|
          path = items['subdomains'][sub]
          subdomain_name = "#{sub}.#{site}"
          subdomains[subdomain_name] = {
            'username' => items.fetch('username'),
            'root_path' => File.join(root_path, trim_slashes(path)),
            'is_subdomain' => true,
            'vhost_file' => File.join('/usr/local/apache2/conf/vhosts/', "#{subdomain_name}.conf"),
            'host' => "#{sub}.#{remove_www(items.fetch('host'))}",
            'ssl' => items.fetch('ssl'),
            'box_name' => @config.fetch('name')
          }
          if collect_hosts then
            add_host(subdomains[subdomain_name].fetch('host'))
          end
        end
      end

      # Merge in settings
      @config['sites'][site] = defaults.merge(items)
    end

    # Merge subdomain sites into `sites` hash
    # Done here to avoid unexpected looping /shrug
    @config['sites'] = @config.fetch('sites').merge(subdomains)

    # Collect and transform host values
    if @config['hosts'].length > 0 then
      # Delete an existing DNS Hosts file
      if File.exist?(@hosts_file) then
        File.delete(@hosts_file)
      end

      # Write the DNS Hosts file
      # To be contatenated onto openssl.cnf during SSL setup
      @config['hosts'].each.with_index(1) do |host, index|
        File.open(@hosts_file, 'a+') { |file| file.puts("DNS.#{index} = #{host}") }
      end

      # Merge the root `hosts` property into a comma-separated string
      @config['hosts'] = @config.fetch('hosts').join(',')
    end

    # Print debug information
    if @config.key?('debug') && @config.fetch('debug') then
      print_debug_info(@config, @vm_config_file_path)
    end
  end
end
