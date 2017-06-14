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
    return trim_ending_slash( trim_beginning_slash( str ) )
  end

  def sanitize_alias(host)
    return ('*.' == host[0..1]) ? host[2..-1] : host
  end

  # De-dup and add site host to root hosts array
  def add_host(host)
    @config['hosts'] = @config.fetch('hosts').push( host ) unless @config.fetch('hosts').include?( host )
  end

  def remove_www(host)
    return ('www' == host[0..2]) ? host[4..-1] : host
  end

  # Helper function for printing error messages
  def handle_error(e, message)
    puts "#{ e.class.name }: #{ message }.".red
    puts "See 'Getting Started': https://github.com/goodguyry/dreambox/wiki".yellow
    trace = e.backtrace.select { |bt| bt.match( File.expand_path( Dir.pwd ) ) }
    puts trace unless defined?( @raw )
    puts trace if @raw.key?('debug') && true == @raw.fetch('debug')
    abort
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

    vagrant_dir = File.expand_path( Dir.pwd )

    # Build the config filepath
    begin
      if defined?( @config_file ) && ( @config_file.kind_of? String )
        @vm_config_file_path = File.join( vagrant_dir, @config_file )
      else
        raise TypeError
      end
    rescue TypeError => e
      handle_error(e, "There was an error with `config_file` declaration: '#{ @config_file }'")
    end

    # Load the config file if found, otherwise abort
    begin
      if File.file?( @vm_config_file_path )
        @raw = YAML.load_file( @vm_config_file_path )
      else
        raise Errno::ENOENT
      end
    rescue Errno::ENOENT => e
      handle_error(e, "Config file not found")
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
    @config = box_defaults.merge( @raw )

    # Abort if the php version isn't one of the two specific options
    begin
      if php_versions.include?( @config.fetch('php') )
        # Set the PHP directory
        @config['php_dir'] = php_dirs[ php_versions.index( @config.fetch('php') ) ]
      else
        raise KeyError
      end
    rescue KeyError => e
      handle_error(e, "Accepted `php` values are '#{ php_versions.first }' and '#{ php_versions.last }")
    end

    # To collect subdomains
    # These will be transformed into sites at the end
    subdomains = {}

    # Collect settings for each site
    @config['sites'].each_key do |dict|
      site = @config['sites'].fetch( dict )

      # Check for required site properties before proceeding
      # If found, remove any errant slashes
      # We allow slashes in the config file to increase readability
      required = ['username', 'root', 'local_root', 'host']
      required.each do |property|
        begin
          if site.fetch( property ).kind_of? String
            site[ property ] = trim_slashes( site.fetch( property ) )
          else
            raise KeyError
          end
        rescue KeyError => e
          handle_error(e, "Missing `#{ property }` for site #{ dict }")
        end
      end

      # Inherit the SSL property if it's not set
      site['ssl'] = @config.fetch('ssl') unless site.key?('ssl')

      # If SSL is enabled globally and not disabled locally, or if enabled locally
      if ( @config.fetch('ssl') && false != site.fetch('ssl') ) || site.fetch('ssl')
        # Enable the root SSL setting if not already enabled
        @config['ssl_enabled'] = ssl_enabled = true
      end

      # Establish site defaults
      defaults = {}
      defaults['box_name'] = @config.fetch('name')
      defaults['is_subdomain'] = false

      # Build paths here rather than in a provisioner
      root_path = File.join('/home/', site.fetch('username'), site.fetch('root'))

      # Account for a `public` folder if set
      site['root_path'] = (site.key?('public')) ?
        File.join( root_path, trim_slashes( site.fetch('public') ) ) : root_path
      site['vhost_file'] = File.join('/usr/local/apache2/conf/vhosts/', "#{ dict }.conf")

      # We only collect host values if SSL is enabled
      if ssl_enabled
        if @config.key?('host')
          add_host( site.fetch('host') )
        else
          @config['host'] = site.fetch('host')
        end
      end

      # Add each of the site's hosts to the root [hosts] property
      if site['aliases'].kind_of? Array
        site['aliases'].each { |the_alias| add_host( sanitize_alias( the_alias ) ) } if ssl_enabled
        # Combine `aliases` into a space-separated string
        site['aliases'] = site.fetch('aliases').join(' ')
      end

      # Collect and merge site subdomains
      # Each subdomain is transformed into it's own site, based on the parent site's config values
      if site['subdomains'].kind_of? Hash
        site['subdomains'].each_key do |sub|
          path = site['subdomains'][ sub ]
          subdomain_name = "#{ sub }.#{ dict }"
          subdomains[ subdomain_name ] = {
            'username' => site.fetch('username'),
            'root_path' => File.join( root_path, trim_slashes( path ) ),
            'is_subdomain' => true,
            'vhost_file' => File.join('/usr/local/apache2/conf/vhosts/', "#{ subdomain_name }.conf"),
            'host' => "#{ sub }.#{ remove_www( site.fetch('host') ) }",
            'ssl' => site.fetch('ssl'),
            'box_name' => @config.fetch('name')
          }
          add_host( subdomains[ subdomain_name ].fetch('host') ) if ssl_enabled
        end
      end

      # Merge in settings
      @config['sites'][ dict ] = defaults.merge( site )
    end

    # Merge subdomain sites into `sites` hash
    # Done here to avoid unexpected looping /shrug
    @config['sites'] = @config.fetch('sites').merge( subdomains )

    # Collect and transform host values
    if @config['hosts'].length > 0
      # Delete an existing DNS Hosts file
      File.delete( @hosts_file ) if File.exist?( @hosts_file )

      # Write the DNS Hosts file
      # To be contatenated onto openssl.cnf during SSL setup
      @config['hosts'].each.with_index(1) do |host, index|
        File.open( @hosts_file, 'a+' ) { |file| file.puts("DNS.#{ index } = #{ host }") }
      end

      # Merge the root `hosts` property into a comma-separated string
      @config['hosts'] = @config.fetch('hosts').join(',')
    end

    # Print debug information
    print_debug_info( @config, @vm_config_file_path ) if @config.key?('debug') && @config.fetch('debug')
  end
end
