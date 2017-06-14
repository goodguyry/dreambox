require_relative 'class_tests.rb'

# Relevant test directories
@assertions_dir = File.join( File.dirname( __FILE__ ), 'assertions' )
@configs_dir = File.join( File.dirname( __FILE__ ), 'configs' )

# Array of configs filenames without extension
configs = Dir[ File.join( @configs_dir, '*.yaml' ) ]

# Instantiate a new Test object
@tests = Tests.new(configs)

# Require tests here
# .rb files in tests/assertsions/ will be auto-required
assertions = Dir.entries( @assertions_dir ).reject { |f| File.directory? f }

assertions.each do |assertion|
  if '.rb' == File.extname( assertion )
    require_relative File.join('assertions', assertion)
  end
end

# Run tests
@tests.run
@tests.print_stats
