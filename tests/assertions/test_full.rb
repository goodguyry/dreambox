# Test configuration featuring multiple sites with full feature set
#
# The hosts list should contain only the first site's host,
# aliases and subdomains, because:
# - Only one site is missing an `ssl` setting, so the site
#   inherits the root SSL value.
# - There is a host declared on the config root `host`
#   property, so the site's host doesn't need to be repurposed
#   as the root host.

config_file = 'tests/configs/full.yaml'
temp_file = File.join(File.dirname(__FILE__), 'test_full_dns_hosts.txt')
full = Config.new(config_file, temp_file)

@tests.cleanup.push(temp_file)

@tests.assertions.push(*[
  # PHP Directory
  {
    'name' => 'Full: PHP Directory should match config PHP version',
    'expect' => 'php70',
    'actual' => full.config['php_dir'],
  },

  # Root SSL
  {
    'name' => 'Full: Root SSL should be enabled',
    'expect' => true,
    'actual' => full.config['ssl_enabled'],
  },

  # Root hosts list
  {
    'name' => 'Full: Root hosts list should only contain SSL-enabled hosts',
    'expect' => 'www.example.dev,example.dev,app.example.dev',
    'actual' => full.config['hosts'],
  },

  # Root path with public folder
  {
    'name' => 'Full: Root path with public folder',
    'expect' => '/home/user/example.com/public',
    'actual' => full.config['sites']['full']['root_path'],
  },

  # Root path, no public folder
  {
    'name' => 'Full: Root path, no public folder',
    'expect' => '/home/user-two/example-two.com',
    'actual' => full.config['sites']['minimal']['root_path'],
  },

  # Subdomain root path with public folder
  {
    'name' => 'Full: Subdomain root path with public folder',
    'expect' => '/home/user/example.com/public/app',
    'actual' => full.config['sites']['app.full']['root_path'],
  },

  # Subdomain root path, no public folder
  {
    'name' => 'Full: Subdomain root path, no public folder',
    'expect' => '/home/user-two/example-two.com/app/help',
    'actual' => full.config['sites']['help.minimal']['root_path'],
  },

  # vhost.conf file path
  {
    'name' => 'Full: vhost.conf file path',
    'expect' => '/usr/local/apache2/conf/vhosts/full.conf',
    'actual' => full.config['sites']['full']['vhost_file'],
  },

  # Subdomain vhost.conf file path
  {
    'name' => 'Full: Subdomain vhost.conf file path',
    'expect' => '/usr/local/apache2/conf/vhosts/app.full.conf',
    'actual' => full.config['sites']['app.full']['vhost_file'],
  },

  # Subdomain host
  {
    'name' => 'Full: Subdomain host',
    'expect' => 'help.example-two.dev',
    'actual' => full.config['sites']['help.minimal']['host'],
  },

  # Subdomain host, parent has `www.` prefix
  {
    'name' => 'Full: Subdomain host, parent has `www.` prefix',
    'expect' => 'app.example.dev',
    'actual' => full.config['sites']['app.full']['host'],
  },

  # Subdomain SSL, parent has SSL enabled
  {
    'name' => 'Full: Subdomain SSL, parent has SSL enabled',
    'expect' => true,
    'actual' => full.config['sites']['app.full']['ssl'],
  },

  # Subdomain SSL, parent has SSL disabled
  {
    'name' => 'Full: Subdomain SSL, parent has SSL disabled',
    'expect' => false,
    'actual' => full.config['sites']['help.minimal']['ssl'],
  },

  # DNS Hosts file
  {
    'name' => 'Full: DNS Hosts file should exist and contain all SSL-enabled hosts',
    'expect' => File.open(temp_file, 'r').read.split("\n"),
    'actual' => [
      'DNS.1 = www.example.dev',
      'DNS.2 = example.dev',
      'DNS.3 = app.example.dev',
    ],
  },
])
