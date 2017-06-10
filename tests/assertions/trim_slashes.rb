#!/usr/bin/env ruby

# trim_slashes
# Tests configutation values output by the `trim_slashes`,
# `trim_ending_slash` and `trim_beginning_slash` helper functions

@tests.assertions.push(*[

  # Condition:
  # - A String contains beginning and ending slashes.
  #
  # Expected Outcome:
  # - The eginning and ending slashes should be removed.
  {
    'name' => 'trim_slashes: The eginning and ending slashes should be removed.',
    'expect' => 'path/to/directory',
    'actual' => trim_slashes('/path/to/directory/'),
  },

  # Condition:
  # - A String does not contain beginning nor ending slashes.
  #
  # Expected Outcome:
  # - The String should not be altered.
  {
    'name' => 'trim_slashes: The String should not be altered.',
    'expect' => 'path/to/directory',
    'actual' => trim_slashes('path/to/directory'),
  },

  # Condition:
  # - A String contains an ending slash.
  #
  # Expected Outcome:
  # - The ending slash should be removed.
  {
    'name' => 'trim_ending_slash: The ending slash should be removed.',
    'expect' => '/path/to/directory',
    'actual' => trim_ending_slash('/path/to/directory/'),
  },

  # Condition:
  # - A String does not contain an ending slash.
  #
  # Expected Outcome:
  # - The String should not be altered.
  {
    'name' => 'trim_ending_slash: The String should not be altered.',
    'expect' => '/path/to/directory',
    'actual' => trim_ending_slash('/path/to/directory'),
  },

  # Condition:
  # - A String contains a beginning slash.
  #
  # Expected Outcome:
  # - The beginning slash should be removed.
  {
    'name' => 'trim_beginning_slash: The beginning slash should be removed.',
    'expect' => 'path/to/directory/',
    'actual' => trim_beginning_slash('/path/to/directory/'),
  },

  # Condition:
  # - A String does not contain a beginning slash.
  #
  # Expected Outcome:
  # - The String should not be altered.
  {
    'name' => 'trim_beginning_slash: The String should not be altered.',
    'expect' => 'path/to/directory/',
    'actual' => trim_beginning_slash('path/to/directory/'),
  },
])
