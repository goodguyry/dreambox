ssl_off_config_file = 'tests/configs/test_ssl_off.yaml'
ssl_off_dns_hosts_file = File.join(File.dirname(__FILE__), 'test_ssl_off_dns_hosts.txt')
ssl_off = Config.new(ssl_off_config_file, ssl_off_dns_hosts_file)

@tests.assertions.push(*[
  # Gobal Test
  #
  # Global SSL setting
  # `ssl_enabled`
  {
    'name' => 'box.ssl_enabled',
    'expect' => false,
    'actual' => ssl_off.config['ssl_enabled'],
  },

  # Gobal Test
  #
  # hosts list
  {
    'name' => 'box.hosts',
    'expect' => '',
    'actual' => ssl_off.config['hosts'],
  },

  # Site Test
  #
  # Site SSL inherited from root
  {
    'name' => 'sites.local-offinherit.ssl',
    'expect' => false,
    'actual' => ssl_off.config['sites']['local-offinherit']['ssl'],
  },

  # Site Test
  #
  # Site SSL locally set to `true`
  {
    'name' => 'sites.local-on.ssl',
    'expect' => true,
    'actual' => ssl_off.config['sites']['local-on']['ssl'],
  },

  # Global Test
  #
  # DNS Hosts file with SSL inherited from `false`
  {
    'name' => 'DNS Hosts file',
    'expect' => File.exist?(ssl_off_dns_hosts_file),
    'actual' => false,
  },

  # Global Test
  #
  # DNS Hosts file with SSL locally set to `true`
  {
    'name' => 'DNS Hosts file',
    'expect' => File.exist?(ssl_off_dns_hosts_file),
    'actual' => false,
  },
])
