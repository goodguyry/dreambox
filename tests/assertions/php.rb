#!/usr/bin/env ruby

# PHP
# Tests configutation values associated with the PHP version

@tests.assertions.push(*[

  ## ===> Default (Missing)

  # Condition:
  # - The root `php` property is not declared.
  #
  # Expected Outcome:
  # - The root `php` value should default to '70'.
  {
    'name' => "Missing PHP: The root `php` value should default to '70'.",
    'expect' => '70',
    'actual' => @tests.the['required'].config['php'],
  },

  # Condition:
  # - The root `php` property is not declared.
  #
  # Expected Outcome:
  # - The root `php_dir` property should default to 'php70'.
  {
    'name' => "Missing PHP: The root `php_dir` property should default to 'php70'.",
    'expect' => 'php70',
    'actual' => @tests.the['required'].config['php_dir'],
  },

  ## ===> PHP 71

  # Condition:
  # - The root `php` value is '71'.
  #
  # Expected Outcome:
  # - The root `php_dir` value should match the config version.
  {
    'name' => "PHP 71: The root `php_dir` value should match the config version.",
    'expect' => 'php71',
    'actual' => @tests.the['full'].config['php_dir'],
  },

  ## ===> Inherited or Overridden

  # Conditions:
  # - The root `php` value is '71'.
  # - The site `php` value is '56'.
  #
  # Expected Outcome:
  # - The site's `php_dir` value should override the root value.
  {
    'name' => "PHP Override: The site's `php_dir` value should override the root value.",
    'expect' => 'php56',
    'actual' => @tests.the['full'].config['sites']['full-one']['php_dir'],
  },

  # Conditions:
  # - The root `php` value is '71'.
  # - The site `php` value is '56'.
  #
  # Expected Outcome:
  # - The site's `php` value should match the site's version.
  {
    'name' => "PHP Override: The site's `php` value should match the site's version.",
    'expect' => 'php56',
    'actual' => @tests.the['full'].config['sites']['full-one']['php_dir'],
  },

  # Condition:
  # - The root `php` property is not declared.
  #
  # Expected Outcome:
  # - The site `php_dir` property should inherit the default version from the root.
  {
    'name' => "Missing PHP: The site's `php_dir` value should override the root value.",
    'expect' => 'php56',
    'actual' => @tests.the['typical'].config['sites']['typical-one']['php_dir'],
  },

  ## ===> Multiple value types for PHP

  # Condition:
  # - The site `php` value is 56 (non-string value).
  #
  # Expected Outcome:
  # - A PHP value declared as a number should be converted to a string.
  {
    'name' => "PHP Number: A PHP value declared as a number should be converted to a string.",
    'expect' => '56',
    'actual' => @tests.the['typical'].config['sites']['typical-one']['php'],
  },

])
