#!/usr/bin/env ruby

# Aliases
# Tests configutation values associated with sites' `aliases` property

@tests.assertions.push(*[

  # Condition:
  # - A site has aliases declared.
  #
  # Expected Outcome:
  # - The site's aliases should be combined into a space-separated String.
  {
    'name' => "Aliases: Aliases should be combined into a space-separated String",
    'expect' => 'www.example.dev *.example.dev',
    'actual' => @tests.the['typical'].config['sites']['typical-one']['aliases'],
  },

  # Condition:
  # - A site has aliases declared in the alternate, square bracket syntax.
  #
  # Expected Outcome:
  # - The site's aliases should be combined into a space-separated String.
  {
    'name' => "Aliases (Alt syntax): Aliases should be combined into a space-separated String",
    'expect' => 'www.example-two.dev *.example-two.dev',
    'actual' => @tests.the['typical'].config['sites']['typical-two']['aliases'],
  },

])
