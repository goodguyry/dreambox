class Tests
  attr_accessor :assertions

  def initialize
    @assertions = Array.new
    @failing = Array.new
    @passing = Array.new
    @tests_run = 0
  end

  # Print test stats
  def print_stats
    puts ''
    puts "==> #{@passing.length}/#{@tests_run} tests passed".bold.green

    if (@failing.length > 0) then
      puts "==> #{@failing.length}/#{@tests_run} tests failed".bold.red
      @failing.each do |message|
        puts "\nFailed #{message}".bold.red
      end
    end
  end

  def run
    @assertions.each do |test|
      # Test assert condition
      condition_met = (test['expect'] == test['actual'])
      if (false == test['assert']) then
        condition_met = (test['expect'] != test['actual'])
      end

      # Test for equal values
      if ! (condition_met) then
        message = "`#{test['name']}` was '#{test['actual']}'; expected '#{test['expect']}'"
        @failing.push(message)
      else
        @passing.push("`#{test['name']}` value")
      end
      @tests_run += 1
    end
  end
end
