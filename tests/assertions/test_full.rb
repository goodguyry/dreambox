full_config_file = 'tests/configs/test_full.yaml'
full_dns_hosts_file = File.join(File.dirname(__FILE__), 'test_full_dns_hosts.txt')
full = Config.new(full_config_file, full_dns_hosts_file)

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
    'expect' => 'www.fullconfig.dev,fullconfig.dev,app.fullconfig.dev',
    'actual' => full.config['hosts'],
  },

  # Root path with public folder
  {
    'name' => 'Full: Root path with public folder',
    'expect' => '/home/fc_user/fullconfig.com/public',
    'actual' => full.config['sites']['full']['root_path'],
  },

  # Root path, no public folder
  {
    'name' => 'Full: Root path, no public folder',
    'expect' => '/home/mc_user/minimalconfig.com',
    'actual' => full.config['sites']['minimal']['root_path'],
  },

  # Subdomain root path with public folder
  {
    'name' => 'Full: Subdomain root path with public folder',
    'expect' => '/home/fc_user/fullconfig.com/public/app',
    'actual' => full.config['sites']['app.full']['root_path'],
  },

  # Subdomain root path, no public folder
  {
    'name' => 'Full: Subdomain root path, no public folder',
    'expect' => '/home/mc_user/minimalconfig.com/app/help',
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
    'expect' => 'help.minimalconfig.dev',
    'actual' => full.config['sites']['help.minimal']['host'],
  },

  # Subdomain host, parent has `www.` prefix
  {
    'name' => 'Full: Subdomain host, parent has `www.` prefix',
    'expect' => 'app.fullconfig.dev',
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
    'expect' => File.open(full_dns_hosts_file, 'r').read.split("\n"),
    'actual' => [
      'DNS.1 = www.fullconfig.dev',
      'DNS.2 = fullconfig.dev',
      'DNS.3 = app.fullconfig.dev',
    ],
  },
])