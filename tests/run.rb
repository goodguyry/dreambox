$vm_config_file = 'tests/test_config.yaml'
require_relative 'utils.rb'

require_relative '../templates/config-setup.rb'
vm_config = Config::VM_CONFIG

@tests_run = 0;
@failing = []
@passing = []

expect_type('box.name', vm_config['name'], String)
expect_value('box.name', vm_config['name'], 'dreambox-tests')

# Test stats output
puts ''
puts "==> #{@passing.length}/#{@tests_run} tests passed".bold.green
puts "==> #{@failing.length}/#{@tests_run} tests failed".bold.red

if (@failing.length) then
  @failing.each do |failed|
    print_failed_test(failed)
  end
end
