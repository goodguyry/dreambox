# Helper function for printing error messages
def print_failed_test(message)
  puts "\n==> #{message}".bold.red
end

# Test for expected type
def expect_type(pointer, value, type)
  if ! (value.kind_of? type) then
    message = "`#{pointer}` was expected to be type `#{type}`"
    @failing.push(message)
  else
    @passing.push("`#{pointer}` type")
  end
  @tests_run += 1
end

# Test for equal values
def expect_value(pointer, value, expected)
  if ! (expected == value) then
    message = "`#{pointer}` was '#{value}'; expected '#{expected}'"
    @failing.push(message)
  else
    @passing.push("`#{pointer}` value")
  end
  @tests_run += 1
end

# Print test stats
def print_stats
  puts ''
  puts "==> #{@passing.length}/#{@tests_run} tests passed".bold.green

  if (@failing.length > 0) then
    puts "==> #{@failing.length}/#{@tests_run} tests failed".bold.red
    @failing.each do |failed|
      print_failed_test(failed)
    end
  end
end
