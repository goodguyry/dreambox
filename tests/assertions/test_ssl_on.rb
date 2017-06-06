# Test configuration featuring SSL enabled at the root
# but disabled in one site.
#
# The disabled site's SSL setting should override the root
# setting for that site, while not affecting the other
# site.
#
# The hosts list should be empty, because:
# - Only one site is missing an `ssl` setting, so the site
#   inherits the root SSL value.
# - The site missing an `ssl` setting has one host declared,
#   with zero aliases. The site's sole host will be saved as
#   the 'main' host at the root. Had there been a host
#   declared on the config root `host` property, the host
#   list would not be empty.

@tests.assertions.push(*[
  # Root SSL should be enabled
  {
    'name' => 'SSL On: Root SSL should be enabled',
    'expect' => true,
    'actual' => @tests.configs['ssl_on'].config['ssl_enabled'],
  },

  # Hosts list should contain only SSL-enabled hosts
  {
    'name' => 'SSL On: Hosts list should contain only SSL-enabled hosts',
    'expect' => 'example.dev',
    'actual' => @tests.configs['ssl_on'].config['hosts'],
  },

  # Site SSL should be inherited from root seting
  {
    'name' => 'SSL On: Site SSL should be inherited from root seting',
    'expect' => true,
    'actual' => @tests.configs['ssl_on'].config['sites']['local-oninherit']['ssl'],
  },

  # Site SSL should override root setting
  {
    'name' => 'SSL On: Site SSL should override root setting',
    'expect' => false,
    'actual' => @tests.configs['ssl_on'].config['sites']['local-off']['ssl'],
  },

  # DNS Hosts file should not be created
  {
    'name' => 'SSL On: DNS Hosts file should not be created',
    'expect' => File.exist?(File.join(@assertions_dir, 'ssl_on.txt')),
    'actual' => false,
  },
])
