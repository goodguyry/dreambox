#!/usr/bin/env ruby

# Box
# Tests miscellaneous box configutation values

@tests.assertions.push(*[

  # Condition:
  # - The root `name` property is not declared.
  #
  # Expected Outcome:
  # - The root `name` property should fall back to 'dreambox'.
  {
    'name' => "Box Name: The root `name` property should fall back to 'dreambox'.",
    'expect' => 'dreambox',
    'actual' => @tests.configs['required'].config['name'],
  },

  # Condition:
  # - The root `name` property has a valid String value.
  #
  # Expected Outcome:
  # - The root `name` value should be identical to raw YAML value.
  {
    'name' => "Box Name: The root `name` property should be identical to raw YAML value.",
    'expect' => 'dreambox-tests',
    'actual' => @tests.configs['full'].config['name'],
  },

])
