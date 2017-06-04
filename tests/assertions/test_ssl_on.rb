config_file = 'tests/configs/test_ssl_on.yaml'
temp_file = File.join(File.dirname(__FILE__), 'test_ssl_on_dns_hosts.txt')
ssl_on = Config.new(config_file, temp_file)

@tests.cleanup.push(temp_file)

@tests.assertions.push(*[
  # Root SSL should be enabled
  {
    'name' => 'SSL On: Root SSL should be enabled',
    'expect' => true,
    'actual' => ssl_on.config['ssl_enabled'],
  },

  # Hosts list should contain only SSL-enabled hosts
  {
    'name' => 'SSL On: Hosts list should contain only SSL-enabled hosts',
    'expect' => 'example.dev',
    'actual' => ssl_on.config['hosts'],
  },

  # Site SSL should be inherited from root seting
  {
    'name' => 'SSL On: Site SSL should be inherited from root seting',
    'expect' => true,
    'actual' => ssl_on.config['sites']['local-oninherit']['ssl'],
  },

  # Site SSL should override root setting
  {
    'name' => 'SSL On: Site SSL should override root setting',
    'expect' => false,
    'actual' => ssl_on.config['sites']['local-off']['ssl'],
  },

  # DNS Hosts file should not be created
  {
    'name' => 'SSL On: DNS Hosts file should not be created',
    'expect' => File.exist?(temp_file),
    'actual' => false,
  },
])
