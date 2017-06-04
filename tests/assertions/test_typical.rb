# Test configuration featuring a typical setup
#
# The root host inherit the first SSL-enabled host declared. The
# hosts list should contain only SSL-enabled aliases.

config_file = 'tests/configs/typical.yaml'
temp_file = File.join(File.dirname(__FILE__), 'test_typical_dns_hosts.txt')
typical = Config.new(config_file, temp_file)

@tests.cleanup.push(temp_file)

@tests.assertions.push(*[
  # Root host
  {
    'name' => 'Typical: Root host should be the first SSL-enabled host declared',
    'expect' => 'example-two.dev',
    'actual' => typical.config['host'],
  },

  # Root hosts list
  {
    'name' => 'Typical: Root hosts list should only contain SSL-enabled hosts',
    'expect' => 'www.example-two.dev,*.example-two.dev',
    'actual' => typical.config['hosts'],
  },

  # DNS Hosts file
  {
    'name' => 'Typical: DNS Hosts file should exist and contain all SSL-enabled hosts',
    'expect' => File.open(temp_file, 'r').read.split("\n"),
    'actual' => [
      'DNS.1 = www.example-two.dev',
      'DNS.2 = *.example-two.dev',
    ],
  },
])
