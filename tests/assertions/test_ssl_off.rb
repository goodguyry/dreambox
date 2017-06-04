ssl_off_config_file = 'tests/configs/test_ssl_off.yaml'
ssl_off_dns_hosts_file = File.join(File.dirname(__FILE__), 'test_ssl_off_dns_hosts.txt')
ssl_off = Config.new(ssl_off_config_file, ssl_off_dns_hosts_file)

@tests.cleanup.push(ssl_off_dns_hosts_file)

@tests.assertions.push(*[
  # Root SSL
  {
    'name' => 'SSL Off: Root `ssl_enabled` should be true',
    'expect' => true,
    'actual' => ssl_off.config['ssl_enabled'],
  },

  # Hosts list
  {
    'name' => 'SSL Off: Hosts list should be empty',
    'expect' => '',
    'actual' => ssl_off.config['hosts'],
  },

  # Inherit site SSL setting
  {
    'name' => 'SSL Off: Site SSL setting should inherit from root',
    'expect' => false,
    'actual' => ssl_off.config['sites']['local-offinherit']['ssl'],
  },

  # Site SSL
  {
    'name' => 'SSL Off: Site SSL should override root setting',
    'expect' => true,
    'actual' => ssl_off.config['sites']['local-on']['ssl'],
  },

  # DNS Hosts file
  {
    'name' => 'SSL Off: DNS Hosts file should not be created',
    'expect' => File.exist?(ssl_off_dns_hosts_file),
    'actual' => false,
  },
])
