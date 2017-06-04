# Test configuration featuring SSL disabled at the root
# but enabled in one site.
#
# The enabed site's SSL setting should override the root
# setting for that site, while not affecting the other
# site.
#
# The root `ssl_enabled` setting, created by the Config
# class, should be set to true to reflect that there is
# at least one site whose SSL setting is enabled.
#
# The hosts list should be empty, because:
# - Only one site has SSL enabled.
# - The site with SSL enabled has one host declared, with
#   zero aliases. The site's sole host will be saved as
#   the 'main' host at the root. Had there been a host
#   declared on the config root `host` property, the host
#   list would not be empty.

config_file = 'tests/configs/test_ssl_off.yaml'
temp_file = File.join(File.dirname(__FILE__), 'test_ssl_off_dns_hosts.txt')
ssl_off = Config.new(config_file, temp_file)

@tests.cleanup.push(temp_file)

@tests.assertions.push(*[
  # Root SSL
  {
    'name' => 'SSL Off: Root `ssl_enabled` should be true',
    'expect' => true, # See note in description for why
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
    'expect' => File.exist?(temp_file),
    'actual' => false,
  },
])
