require_relative 'class_tests.rb'

@assertions_dir = File.join(File.dirname(__FILE__), 'assertions')

# Array of configs filenames without extension
configs = [
  'required',
  'full',
  'typical',
  'ssl_off',
  'ssl_on',
]

# Instantiate a new Test object
@tests = Tests.new(configs)

# Require tests here
require_relative 'assertions/test_full.rb'
require_relative 'assertions/test_typical.rb'
require_relative 'assertions/test_required.rb'
require_relative 'assertions/test_ssl_off.rb'
require_relative 'assertions/test_ssl_on.rb'
require_relative 'assertions/test_utilities.rb'

# Run tests
@tests.run
@tests.print_stats
