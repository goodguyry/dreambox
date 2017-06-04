ssl_on_config_file = 'tests/test_ssl_on.yaml'
ssl_on_dns_hosts_file = File.join(File.dirname(__FILE__), 'test_ssl_on_dns_hosts.txt')
ssl_on = Config.new(ssl_on_config_file, ssl_on_dns_hosts_file)

@tests.assertions.push(*[
  # Gobal Test
  #
  # Global SSL setting
  # `ssl_enabled`
  {
    'name' => 'box.ssl_enabled',
    'expect' => true,
    'actual' => ssl_on.config['ssl_enabled'],
  },

  # Gobal Test
  #
  # hosts list
  {
    'name' => 'box.hosts',
    'expect' => 'ssloninherit.dev',
    'actual' => ssl_on.config['hosts'],
  },

  # Site Test
  #
  # Site SSL inherited from root
  {
    'name' => 'sites.local-oninherit.ssl',
    'expect' => true,
    'actual' => ssl_on.config['sites']['local-oninherit']['ssl'],
  },

  # Site Test
  #
  # Site SSL locally set to `true`
  {
    'name' => 'sites.local-off.ssl',
    'expect' => false,
    'actual' => ssl_on.config['sites']['local-off']['ssl'],
  },

  # Global Test
  #
  # DNS Hosts file with SSL inherited from `false`
  {
    'name' => 'DNS Hosts file',
    'expect' => File.exist?(ssl_on_dns_hosts_file),
    'actual' => false,
  },

  # Global Test
  #
  # DNS Hosts file with SSL locally set to `true`
  {
    'name' => 'DNS Hosts file',
    'expect' => File.exist?(ssl_on_dns_hosts_file),
    'actual' => false,
  },
])
