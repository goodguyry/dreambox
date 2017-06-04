required_config_file = 'tests/configs/test_required.yaml'
required_dns_hosts_file = File.join(File.dirname(__FILE__), 'test_required_dns_hosts.txt')
required = Config.new(required_config_file, required_dns_hosts_file)

@tests.assertions.push(*[
  # Missing box name
  {
    'name' => "Required: Missing box name should fall back to default 'dreambox'",
    'expect' => 'dreambox',
    'actual' => required.config['name'],
  },

  # PHP version
  {
    'name' => "Required: PHP version should fall back to default '5'",
    'expect' => '5',
    'actual' => required.config['php'],
  },

  # PHP directory
  {
    'name' => "Required: PHP directory should fall back to 'php_56'",
    'expect' => 'php56',
    'actual' => required.config['php_dir'],
  },

  # Missing SSL setting
  {
    'name' => 'Required: Missing SSL setting should fall back to default `false`',
    'expect' => false,
    'actual' => required.config['ssl_enabled'],
  },

  # Hosts list
  {
    'name' => 'Required: Hosts list should be empty',
    'expect' => '',
    'actual' => required.config['hosts'],
  },

  # DNS Hosts
  {
    'name' => 'Required: DNS Hosts should not be created',
    'expect' => false,
    'actual' => File.exist?(required_dns_hosts_file),
  },


  # Root path
  {
    'name' => 'Required: Root path',
    'expect' => '/home/rc_user/requiredconfig.com',
    'actual' => required.config['sites']['required']['root_path'],
  },

  # vhost.conf file path
  {
    'name' => 'Required: vhost.conf file path',
    'expect' => '/usr/local/apache2/conf/vhosts/required.conf',
    'actual' => required.config['sites']['required']['vhost_file'],
  },
])
