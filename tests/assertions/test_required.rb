# Test configuration featuring only required settings
#
# The box defaults will be inherited by this config:
# - PHP version 5
# - SSL disabled
# - 'dreambox' box name

@tests.assertions.push(*[
  # Missing box name
  {
    'name' => "Required: Missing box name should fall back to default 'dreambox'",
    'expect' => 'dreambox',
    'actual' => @tests.configs['required'].config['name'],
  },

  # PHP version
  {
    'name' => "Required: PHP version should fall back to default '5'",
    'expect' => '5',
    'actual' => @tests.configs['required'].config['php'],
  },

  # PHP directory
  {
    'name' => "Required: PHP directory should fall back to 'php_56'",
    'expect' => 'php56',
    'actual' => @tests.configs['required'].config['php_dir'],
  },

  # Missing SSL setting
  {
    'name' => 'Required: Missing SSL setting should fall back to default `false`',
    'expect' => false,
    'actual' => @tests.configs['required'].config['ssl_enabled'],
  },

  # Hosts list
  {
    'name' => 'Required: Hosts list should be empty',
    'expect' => '',
    'actual' => @tests.configs['required'].config['hosts'],
  },

  # DNS Hosts
  {
    'name' => 'Required: DNS Hosts should not be created',
    'expect' => false,
    'actual' => File.exist?(File.join(@assertions_dir, 'required.txt')),
  },


  # Root path
  {
    'name' => 'Required: Root path',
    'expect' => '/home/user/example.com',
    'actual' => @tests.configs['required'].config['sites']['required']['root_path'],
  },

  # vhost.conf file path
  {
    'name' => 'Required: vhost.conf file path',
    'expect' => '/usr/local/apache2/conf/vhosts/required.conf',
    'actual' => @tests.configs['required'].config['sites']['required']['vhost_file'],
  },
])
