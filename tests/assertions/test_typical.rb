# Test configuration featuring a typical setup
#
# The root host inherit the first SSL-enabled host declared. The
# hosts list should contain only SSL-enabled aliases.

@tests.assertions.push(*[
  # Root host
  {
    'name' => 'Typical: Root host should be the first SSL-enabled host declared',
    'expect' => 'example-two.dev',
    'actual' => @tests.configs['typical'].config['host'],
  },

  # Root hosts list
  {
    'name' => 'Typical: Root hosts list should only contain SSL-enabled hosts',
    'expect' => 'www.example-two.dev,*.example-two.dev',
    'actual' => @tests.configs['typical'].config['hosts'],
  },

  # DNS Hosts file
  {
    'name' => 'Typical: DNS Hosts file should exist and contain all SSL-enabled hosts',
    'expect' => File.open(File.join(@assertions_dir, 'typical.txt'), 'r').read.split("\n"),
    'actual' => [
      'DNS.1 = www.example-two.dev',
      'DNS.2 = *.example-two.dev',
    ],
  },
])
