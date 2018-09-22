#!/usr/bin/env ruby

# User
# Tests configutation values associated with sites' `database` property

@tests.assertions.push(*[

  # Condition:
  # - A site has a database name declared.
  #
  # Expected Outcome:
  # - The site's database name should exist and be correct.
  {
    'name' => "Database: Database should exist",
    'expect' => 'full_one_db',
    'actual' => @tests.the['full'].config['sites']['full-one']['database'],
  },

  # Condition:
  # - A site does not have a database name declared.
  #
  # Expected Outcome:
  # - The site's database name should be `false`.
  {
    'name' => "Database: Database should not exist",
    'expect' => false,
    'actual' => @tests.the['typical'].config['sites']['typical-one']['database'],
  }

])
