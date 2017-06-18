#!/usr/bin/env ruby

require 'yaml'
require_relative 'utilities.rb'

# Config class
#
# The Config class collects and transforms the config file's values to prepare them
# for the Dreambox provisioning scripts.
class Config
  include Helpers

  attr_accessor :config
  attr_reader :raw

  # Allowed PHP values
  PHP_VERSIONS = ['5', '7']
  # Associated PHP install directories
  PHP_DIRS = ['php56', 'php70']

  # Class initialization
  #
  # @param String {config_file} The path to the config file
  # @param String {hosts_file} The location at which to create the DNS Hosts file
  def initialize(config_file, hosts_file)
    @hosts_file = hosts_file
    collect_config_values if validates(config_file)
  end

  def validates(config_file)
    vagrant_dir = File.expand_path(Dir.pwd)

    begin
      raise TypeError unless defined?(config_file) && (config_file.kind_of? String)
    rescue TypeError => e
      handle_error(e, "There was an error with `config_file` declaration: '#{config_file}'")
    end

    # Build the config filepath
    @config_config_file_path = File.join(vagrant_dir, config_file)

    begin
      raise Errno::ENOENT unless File.file?(@config_config_file_path)
    rescue Errno::ENOENT => e
      handle_error(e, "Config file not found")
    end

    # Load the config file if found, otherwise abort
    @raw = YAML.load_file(@config_config_file_path)

    # Set config defaults
    box_defaults = {}
    box_defaults['name'] = 'dreambox'
    box_defaults['php'] = PHP_VERSIONS.first
    box_defaults['ssl'] = false
    box_defaults['ssl_enabled'] = false
    box_defaults['hosts'] = []

    # Merge the default 'box' values with those from vm-config
    @raw = box_defaults.merge(@raw)

    # Abort if the php version isn't one of the two specific options
    begin
      raise KeyError unless PHP_VERSIONS.include?(@raw.fetch('php'))
    rescue KeyError => e
      handle_error(e, "Accepted `php` values are '#{PHP_VERSIONS.first}' and '#{PHP_VERSIONS.last}")
    end

    # Validate required site properties before proceeding
    required = ['username', 'root', 'local_root', 'host']
    @raw['sites'].each_key do |dict|
      required.each do |property|
        begin
          raise KeyError unless @raw['sites'].fetch(dict).fetch(property).kind_of? String
        rescue KeyError => e
          handle_error(e, "Missing or incorrect `#{property}` value for site '#{dict}'")
        end
      end
    end
  end

  def collect_config_values
    # To collect subdomains
    # These will be transformed into sites at the end
    subdomains = {}

    @config = {}.merge(@raw)

    # Collect settings for each site
    @config['sites'].each_key do |dict|
      site = @config['sites'].fetch(dict)

      # Inherit the SSL property if it's not set
      site['ssl'] = @config.fetch('ssl') unless site.key?('ssl')

      site['local_root'] = trim_slashes(@config['sites'].fetch(dict).fetch('local_root'))

      # Build paths here rather than in a provisioner
      root_path = File.join('/home/', site.fetch('username'), trim_slashes(site.fetch('root')))

      # Account for a `public` folder if set
      site['root_path'] = (site.key?('public')) ?
        File.join(root_path, trim_slashes(site.fetch('public'))) : root_path
      site['vhost_file'] = File.join('/usr/local/apache2/conf/vhosts/', "#{dict}.conf")

      # Inherit the SSL property if it's not set
      site['ssl'] = @config.fetch('ssl') unless site.key?('ssl')

      # If SSL is enabled globally and not disabled locally, or if enabled locally
      if (@config.fetch('ssl') && false != site.fetch('ssl')) || site.fetch('ssl')
        # Enable the root SSL setting if not already enabled
        @config['ssl_enabled'] = ssl_enabled = true
      end

      # We only collect host values if SSL is enabled
      if ssl_enabled
        if @config.key?('host')
          add_host(site.fetch('host'))
        else
          @config['host'] = site.fetch('host')
        end
      end

      # Add each of the site's hosts to the root [hosts] property
      if site['aliases'].kind_of? Array
        site['aliases'].each { |the_alias| add_host(sanitize_alias(the_alias)) } if ssl_enabled
        # Combine `aliases` into a space-separated string
        site['aliases'] = site.fetch('aliases').join(' ')
      end

      # Collect and merge site subdomains
      # Each subdomain is transformed into it's own site, based on the parent site's config values
      if site['subdomains'].kind_of? Hash
        site['subdomains'].each_key do |sub|
          path = site['subdomains'][sub]
          subdomain_name = "#{sub}.#{dict}"
          subdomains[subdomain_name] = {
            'username' => site.fetch('username'),
            'root_path' => File.join(root_path, trim_slashes(path)),
            'is_subdomain' => true,
            'vhost_file' => File.join('/usr/local/apache2/conf/vhosts/', "#{subdomain_name}.conf"),
            'host' => "#{sub}.#{ remove_www(site.fetch('host')) }",
            'ssl' => site.fetch('ssl'),
            'box_name' => @config.fetch('name')
          }
          add_host(subdomains[subdomain_name].fetch('host')) if ssl_enabled
        end
      end

      # Merge in settings
      @config['sites'][dict] = defaults.merge(site)
    end

    # Merge subdomain sites into `sites` hash
    # Done here to avoid unexpected looping /shrug
    @config['sites'] = @config.fetch('sites').merge(subdomains)

    @config['php_dir'] = PHP_DIRS[PHP_VERSIONS.index(@config.fetch('php'))]

    # Collect and transform host values
    if @config['hosts'].length > 0
      # Delete an existing DNS Hosts file
      File.delete(@hosts_file) if File.exist?(@hosts_file)

      # Write the DNS Hosts file
      # To be contatenated onto openssl.cnf during SSL setup
      @config['hosts'].each.with_index(1) do |host, index|
        File.open(@hosts_file, 'a+') { |file| file.puts("DNS.#{index} = #{host}") }
      end

      # Merge the root `hosts` property into a comma-separated string
      @config['hosts'] = @config.fetch('hosts').join(',')
    end

    # Print debug information
    print_debug_info(@config, @config_config_file_path) if @config.key?('debug') && @config.fetch('debug')
  end
end
