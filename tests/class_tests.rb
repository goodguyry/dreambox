#!/usr/bin/env ruby
require_relative '../templates/class_config.rb'

# Tests class
#
# This class tests an array of assertions, each a hash with a description expected
# value and actual value. The outcome of each test is saved, then printed to stdout
# upon completion of all tests.
#
class Tests
  attr_accessor :the, :assertions

  def initialize(opts)
    @the = {}
    @assertions = []
    @temp_files = []

    opts.each do |opt|
      basename = File.basename( opt, File.extname( opt ) )
      temp_file = File.join( File.dirname( __FILE__ ), "assertions/#{basename}.txt" )
      @the[ basename ] = Config.new( opt, temp_file )
      @temp_files.push( temp_file )
    end
  end

  # Print test stats
  def print_stats
    puts ''
    puts "==> #{ @passing.length }/#{ @tests_run } tests passed".bold.green

    if @failing.length > 0
      puts "==> #{ @failing.length }/#{ @tests_run } tests failed\n".bold.red
      @failing.each do |message|
        puts "#{ message.first }\n"
        printf "Expected  => %s\n".yellow, message.first
        printf "Actual    => %s\n\n".red, message.last
      end
    end
  end

  # Clean up temporary files
  def run_cleanup
    @temp_files.each { |file| File.delete( file ) if File.exist?( file ) }
  end

  # Run the tests
  def run
    @failing = []
    @passing = []
    @tests_run = 0

    @assertions.each do |test|
      # Test assert condition
      condition_met =
        if false == test['assert']
          ! test['expect'].eql? test['actual']
        else
          test['expect'].eql? test['actual']
        end

      # Test for equal values
      if condition_met
        @passing.push("`#{ test['name'] }` value")
      else
        message = test['name'], test['expect'], test['actual']
        @failing.push( message )
      end
      @tests_run += 1
    end
    # Delete temporary test files
    run_cleanup
  end
end
