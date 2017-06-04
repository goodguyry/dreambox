class Tests
  attr_accessor :assertions
  attr_accessor :cleanup

  def initialize
    @assertions = Array.new
    @failing = Array.new
    @passing = Array.new
    @cleanup = Array.new
    @tests_run = 0
  end

  # Print test stats
  def print_stats
    puts ''
    puts "==> #{@passing.length}/#{@tests_run} tests passed".bold.green

    if (@failing.length > 0) then
      puts "==> #{@failing.length}/#{@tests_run} tests failed\n".bold.red
      @failing.each do |message|
        printf "#{message[0]}\n"
        printf "Expected  => %s\n", message[1]
        printf "Actual    => %s\n\n".red, message[2]
      end
    end
  end

  def run_cleanup
    @cleanup.each do |file|
      if File.exist?(file) then
        File.delete(file)
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
        message = test['name'], test['expect'], test['actual']
        @failing.push(message)
      else
        @passing.push("`#{test['name']}` value")
      end
      @tests_run += 1
    end
    # Delete temporary test files
    run_cleanup
  end
end
