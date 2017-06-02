require_relative '../templates/class_config.rb'
require_relative 'class_tests.rb'

@tests = Tests.new

# Add tests here
require_relative 'test_full.rb'
require_relative 'test_required.rb'
require_relative 'test_utilities.rb'

# Run tests
@tests.run
@tests.print_stats
