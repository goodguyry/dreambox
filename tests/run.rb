$vm_config_file = 'tests/test_config.yaml'
require_relative 'utils.rb'

require_relative '../templates/config-setup.rb'
vm_config = Config::VM_CONFIG

@tests_run = 0;
@failing = []
@passing = []

# Type tests
# expect_type('box.name', vm_config['name'], String)

# Value tests
expect_value(
  'box.php_dir',
  vm_config['php_dir'],
  'php70'
)

expect_value(
  'box.ssl_enabled',
  vm_config['ssl_enabled'],
  true
)

expect_value(
  'box.hosts',
  vm_config['hosts'],
  'www.dreambox.test,dreambox.test,app.dreambox.test,example.dev,help.example.dev'
)

# Test stats output
print_stats
