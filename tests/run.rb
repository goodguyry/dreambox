config_file = 'tests/test_config.yaml'

require_relative 'helpers.rb'
require_relative '../templates/class_config.rb'

dns_hosts_file = File.join(File.dirname(__FILE__), 'dns-hosts.txt')
testing = Config.new(config_file, dns_hosts_file)

@tests_run = 0;
@failing = []
@passing = []


# Gobal Test
#
# PHP Directory
# `php_dir`
#
expect_value(
  'box.php_dir',
  testing.config['php_dir'],
  'php70'
)

# Gobal Test
#
# Global SSL setting
# `ssl_enabled`
#
expect_value(
  'box.ssl_enabled',
  testing.config['ssl_enabled'],
  true
)

# Gobal Test
#
# @TODO Replace with test of DNS Hosts file
# hosts list
#
expect_value(
  'box.hosts',
  testing.config['hosts'],
  'www.fullconfig.dev,fullconfig.dev,app.fullconfig.dev,minimalconfig.dev,help.minimalconfig.dev'
)


# Site Test
#
# Root Path
# With public folder
#
expect_value(
  'sites.full.root_path',
  testing.config['sites']['full']['root_path'],
  '/home/fc_user/fullconfig.com/public'
)

# Site Test
#
# Root Path
# No public folder
#
expect_value(
  'sites.minimalconfig.root_path',
  testing.config['sites']['minimal']['root_path'],
  '/home/mc_user/minimalconfig.com'
)

# Site Test
#
# Root Path - Subdomain
# With public folder
#
expect_value(
  'sites.app.full.root_path',
  testing.config['sites']['app.full']['root_path'],
  '/home/fc_user/fullconfig.com/public/app'
)

# Site Test
#
# Root Path - Subdomain
# No public folder
#
expect_value(
  'sites.help.minimal.root_path',
  testing.config['sites']['help.minimal']['root_path'],
  '/home/mc_user/minimalconfig.com/app/help'
)


# Site Test
#
# VHost File
#
expect_value(
  'sites.full.vhost_file',
  testing.config['sites']['full']['vhost_file'],
  '/usr/local/apache2/conf/vhosts/full.conf'
)

# Site Test
#
# VHost File - Subdomain
#
expect_value(
  'sites.app.full.vhost_file',
  testing.config['sites']['app.full']['vhost_file'],
  '/usr/local/apache2/conf/vhosts/app.full.conf'
)


# Site Test
#
# Subdomain Host
# Parent has bare domain
#
expect_value(
  'sites.help.minimal.host',
  testing.config['sites']['help.minimal']['host'],
  'help.minimalconfig.dev'
)

# Site Test
#
# Subdomain Host
# Parent host contains `www.`
#
expect_value(
  'sites.app.full.host',
  testing.config['sites']['app.full']['host'],
  'app.fullconfig.dev'
)

# Site Test
#
# Subdomain SSL
# Parent has SSL enabled
#
expect_value(
  'sites.app.full.ssl',
  testing.config['sites']['app.full']['ssl'],
  true
)

# Site Test
#
# Subdomain SSL
# Parent has SSL disabled
#
expect_value(
  'sites.help.minimal.ssl',
  testing.config['sites']['help.minimal']['ssl'],
  false
)


# Global Test
#
# DNS Hosts file
#
file_contents_array = File.open(dns_hosts_file, 'r').read.split("\n")
test_contents = [
  'DNS.1 = www.fullconfig.dev',
  'DNS.2 = fullconfig.dev',
  'DNS.3 = app.fullconfig.dev',
  'DNS.4 = minimalconfig.dev',
  'DNS.5 = help.minimalconfig.dev'
]

expect_value(
  'DNS Hosts file',
  file_contents_array,
  test_contents
)

# Utility function
#
# trim_slashes
#
expect_value(
  'trim_slashes',
  trim_slashes('/path/to/directory/'),
  'path/to/directory'
)

# Utility function
#
# trim_ending_slash
#
expect_value(
  'trim_ending_slash',
  trim_ending_slash('/path/to/directory/'),
  '/path/to/directory'
)

# Utility function
#
# trim_beginning_slash
#
expect_value(
  'trim_beginning_slash',
  trim_beginning_slash('/path/to/directory/'),
  'path/to/directory/'
)


# Test stats output
print_stats
