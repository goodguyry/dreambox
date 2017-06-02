required_config_file = 'tests/test_required.yaml'
required_dns_hosts_file = File.join(File.dirname(__FILE__), 'test_required_dns_hosts.txt')
required = Config.new(required_config_file, required_dns_hosts_file)

@tests.assertions.push(*[
  # Gobal Test
  #
  # Missing box name should fall back to default 'dreambox'
  {
    'name' => 'required - box.name',
    'expect' => 'dreambox',
    'actual' => required.config['name'],
  },

  # Gobal Test
  #
  # PHP version should fall back to default '5'
  {
    'name' => 'required - box.php',
    'expect' => '5',
    'actual' => required.config['php'],
  },

  # Gobal Test
  #
  # Default PHP version should select 'php_56' as the PHP directory
  {
    'name' => 'required - box.php_dir',
    'expect' => 'php56',
    'actual' => required.config['php_dir'],
  },

  # Gobal Test
  #
  # Missing SSL setting should fall back to default `false`
  {
    'name' => 'required - box.ssl_enabled',
    'expect' => false,
    'actual' => required.config['ssl_enabled'],
  },

  # Gobal Test
  #
  # hosts list
  {
    'name' => 'required - box.hosts',
    'expect' => 'requiredconfig.dev',
    'actual' => required.config['hosts'],
  },

  # Global Test
  #
  # DNS Hosts file
  {
    'name' => 'required - DNS Hosts file exists',
    'expect' => false,
    'actual' => File.exist?(required_dns_hosts_file),
  },


  # Site Test
  #
  # Root Path
  {
    'name' => 'sites.required.root_path',
    'expect' => '/home/rc_user/requiredconfig.com',
    'actual' => required.config['sites']['required']['root_path'],
  },

  # Site Test
  #
  # VHost File
  {
    'name' => 'sites.required.vhost_file',
    'expect' => '/usr/local/apache2/conf/vhosts/required.conf',
    'actual' => required.config['sites']['required']['vhost_file'],
  },
])
