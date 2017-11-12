#!/usr/bin/env ruby

require 'yaml'
require_relative 'utilities.rb'

class Config
  include Helpers

  attr_accessor :config
  attr_reader :raw

  # Class initialization
  #
  # @param String {config_file} The path to the config file
  def initialize(config_file)
    collect_config_values if validates(config_file)
  end

  # Validate
  #
  # Reads the config file and validates necessary values
  def validates(config_file)
    vagrant_dir = File.expand_path(Dir.pwd)

    begin
      raise TypeError unless defined?(config_file) && (config_file.kind_of? String)
    rescue TypeError => e
      handle_error(e, "There was an error with `config_file` declaration: '#{config_file}'")
    end

    @config_config_file_path = File.join(vagrant_dir, config_file)

    begin
      raise Errno::ENOENT unless File.file?(@config_config_file_path)
    rescue Errno::ENOENT => e
      handle_error(e, "Config file not found")
    end

    # Save raw config files for access in the Vagrantfile
    @raw = YAML.load_file(@config_config_file_path)

    # Allowed PHP values and associated PHP install directories
    php_versions = ['5', '7']
    php_dirs = ['php56', 'php70']

    box_defaults = {}
    box_defaults['name'] = 'dreambox'
    box_defaults['php'] = php_versions.first
    box_defaults['ssl'] = false
    box_defaults['ssl_enabled'] = false
    box_defaults['hosts'] = []

    # Fill in the blanks with default values
    @raw = box_defaults.merge(@raw)

    begin
      raise KeyError unless php_versions.include?(@raw.fetch('php'))
    rescue KeyError => e
      handle_error(e, "Accepted `php` values are '#{php_versions.first}' and '#{php_versions.last}")
    end

    @raw['php_dir'] = php_dirs[php_versions.index(@raw.fetch('php'))]

    required_properties = ['user', 'root', 'local_root', 'host']
    @raw['sites'].each_key do |dict|
      required_properties.each do |property|
        begin
          raise KeyError unless @raw['sites'].fetch(dict).fetch(property).kind_of? String
        rescue KeyError => e
          handle_error(e, "Missing or incorrect `#{property}` value for site '#{dict}'")
        end
      end
    end
  end

  # Transforms and collects site property values
  def collect_config_values
    @config = {}.merge(@raw)

    sites = {}
    subdomains = {}

    users = {}
    groups = {}
    user_id = 501
    group_id = 901

    site_defaults = {}
    site_defaults['box_name'] = @config.fetch('name')
    site_defaults['is_subdomain'] = false

    @config['sites'].each_key do |dict|
      # Make a deep copy of the hash so it's not altered as we are iterating
      site = Marshal.load(Marshal.dump(@config['sites'].fetch(dict)))

      # User and Group ID
      # Assign a UID based either on a previously-declared user or a new user
      # Assign a GID based either on a previously-declared group, a new group, or the default

      if users.key?(site['user'])
        site['uid'] = users[site['user']]
      else
        site['uid'] = user_id += 1
        users.merge!(site['user'] => site['uid'])
      end

      site['group'] = 'dreambox' unless site['group']
      if groups.key?(site['group'])
        site['gid'] = groups[site['group']]
      else
        site['gid'] = group_id += 1
        groups.merge!(site['group'] => site['gid'])
      end

      # Paths
      # Clean and build paths used by Vagrant and/or the provisioners

      site['local_root'] = trim_slashes(@config['sites'].fetch(dict).fetch('local_root'))

      root_path = File.join('/home/', site.fetch('user'), trim_slashes(site.fetch('root')))
      site['root_path'] = (site.key?('public')) ?
        File.join(root_path, trim_slashes(site.fetch('public'))) : root_path

      site['vhost_file'] = File.join('/usr/local/apache2/conf/vhosts/', "#{dict}.conf")

      # SSL
      # Inherit the SSL setting from the root unless set in the site
      # The SSL setting informs whether or not hosts and aliases are collected

      site['ssl'] = @config.fetch('ssl') unless site.key?('ssl')

      if (@config.fetch('ssl') && false != site.fetch('ssl')) || site.fetch('ssl')
        @config['ssl_enabled'] = ssl_enabled = true
      end

      if ssl_enabled
        if @config.key?('host')
          add_host(site.fetch('host'))
        else
          @config['host'] = site.fetch('host')
        end
      end

      if site['aliases'].kind_of? Array
        site['aliases'].each { |the_alias| add_host(sanitize_alias(the_alias)) } if ssl_enabled
        # Aliases will be printed in the site's Apache conf
        site['aliases'] = site.fetch('aliases').join(' ')
      end

      # Subdomains
      # Each subdomain is converted to a site hash; gets its own Apache conf

      if site['subdomains'].kind_of? Hash
        site['subdomains'].each_key do |sub|
          path = site['subdomains'][sub]
          subdomain_name = "#{sub}.#{dict}"
          subdomains[subdomain_name] = {
            'user' => site.fetch('user'), # Inherited from the parent site
            'uid' => site.fetch('uid'), # Inherited from the parent site
            'group' => site.fetch('group'), # Inherited from the parent site
            'gid' => site.fetch('gid'), # Inherited from the parent site
            'root_path' => File.join(root_path, trim_slashes(path)),
            'is_subdomain' => true,
            'vhost_file' => File.join('/usr/local/apache2/conf/vhosts/', "#{subdomain_name}.conf"),
            'host' => "#{sub}.#{ remove_www(site.fetch('host')) }",
            'ssl' => site.fetch('ssl'), # Inherited from the parent site
            'box_name' => @config.fetch('name')
          }
          add_host(subdomains[subdomain_name].fetch('host')) if ssl_enabled
        end
      end

      # Clean properties not used by Vagrant and/or provisioners
      site.delete('public')
      site.delete('subdomains')

      # Fill in the blanks with the site default values
      sites[dict] = site_defaults.merge(site)
    end

    # Merge subdomain and sites
    @config['sites'] = @config.fetch('sites').merge(sites)
    @config['sites'] = @config.fetch('sites').merge(subdomains)

    # Add the template root
    @config['template_root'] = @template_root

    # Build the hosts string
    # To be echoed onto openssl.cnf during SSL setup
    @config['hosts'].map!.with_index(1) { |host, index| "DNS.#{index} = #{host}" } if @config['hosts'].length > 0
    delimiter = (@config['hosts'].length > 0) ? '\n' : ''
    @config['hosts'] = @config.fetch('hosts').join(delimiter)

    print_debug_info(@config, @config_config_file_path) if @config.key?('debug') && @config.fetch('debug')
  end
end
