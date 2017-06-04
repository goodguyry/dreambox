full_config_file = 'tests/configs/test_full.yaml'
full_dns_hosts_file = File.join(File.dirname(__FILE__), 'test_full_dns_hosts.txt')
full = Config.new(full_config_file, full_dns_hosts_file)

@tests.assertions.push(*[
  # Gobal Test
  #
  # PHP Directory
  # `php_dir`
  {
    'name' => 'box.php_dir',
    'expect' => 'php70',
    'actual' => full.config['php_dir'],
  },

  # Gobal Test
  #
  # Global SSL setting
  # `ssl_enabled`
  {
    'name' => 'box.ssl_enabled',
    'expect' => true,
    'actual' => full.config['ssl_enabled'],
  },

  # Gobal Test
  #
  # hosts list
  {
    'name' => 'box.hosts',
    'expect' => 'www.fullconfig.dev,fullconfig.dev,app.fullconfig.dev',
    'actual' => full.config['hosts'],
  },

  # Site Test
  #
  # Root Path
  # With public folder
  {
    'name' => 'sites.full.root_path',
    'expect' => '/home/fc_user/fullconfig.com/public',
    'actual' => full.config['sites']['full']['root_path'],
  },

  # Site Test
  #
  # Root Path
  # No public folder
  {
    'name' => 'sites.minimalconfig.root_path',
    'expect' => '/home/mc_user/minimalconfig.com',
    'actual' => full.config['sites']['minimal']['root_path'],
  },

  # Site Test
  #
  # Root Path - Subdomain
  # With public folder
  {
    'name' => 'sites.app.full.root_path',
    'expect' => '/home/fc_user/fullconfig.com/public/app',
    'actual' => full.config['sites']['app.full']['root_path'],
  },

  # Site Test
  #
  # Root Path - Subdomain
  # No public folder
  {
    'name' => 'sites.help.minimal.root_path',
    'expect' => '/home/mc_user/minimalconfig.com/app/help',
    'actual' => full.config['sites']['help.minimal']['root_path'],
  },

  # Site Test
  #
  # VHost File
  {
    'name' => 'sites.full.vhost_file',
    'expect' => '/usr/local/apache2/conf/vhosts/full.conf',
    'actual' => full.config['sites']['full']['vhost_file'],
  },

  # Site Test
  #
  # VHost File - Subdomain
  {
    'name' => 'sites.app.full.vhost_file',
    'expect' => '/usr/local/apache2/conf/vhosts/app.full.conf',
    'actual' => full.config['sites']['app.full']['vhost_file'],
  },

  # Site Test
  #
  # Subdomain Host
  # Parent has bare domain
  {
    'name' => 'sites.help.minimal.host',
    'expect' => 'help.minimalconfig.dev',
    'actual' => full.config['sites']['help.minimal']['host'],
  },

  # Site Test
  #
  # Subdomain Host
  # Parent host contains `www.`
  {
    'name' => 'sites.app.full.host',
    'expect' => 'app.fullconfig.dev',
    'actual' => full.config['sites']['app.full']['host'],
  },

  # Site Test
  #
  # Subdomain SSL
  # Parent has SSL enabled
  {
    'name' => 'sites.app.full.ssl',
    'expect' => true,
    'actual' => full.config['sites']['app.full']['ssl'],
  },

  # Site Test
  #
  # Subdomain SSL
  # Parent has SSL disabled
  {
    'name' => 'sites.help.minimal.ssl',
    'expect' => false,
    'actual' => full.config['sites']['help.minimal']['ssl'],
  },

  # Global Test
  #
  # DNS Hosts file
  {
    'name' => 'DNS Hosts file',
    'expect' => File.open(full_dns_hosts_file, 'r').read.split("\n"),
    'actual' => [
      'DNS.1 = www.fullconfig.dev',
      'DNS.2 = fullconfig.dev',
      'DNS.3 = app.fullconfig.dev',
    ],
  },
])
