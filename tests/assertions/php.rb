#!/usr/bin/env ruby

# PHP
# Tests configutation values associated with the PHP version

@tests.assertions.push(*[

  ## ===> Default (Missing)

  # Condition;
  # - The root `php` property is not declared.
  #
  # Expected Outcome:
  # - The root `php` value should default to '5'.
  {
    'name' => "Missing PHP: The root `php` value should default to '5'.",
    'expect' => '5',
    'actual' => @tests.configs['required'].config['php'],
  },

  # Condition;
  # - The root `php` property is not declared.
  #
  # Expected Outcome:
  # - The root `php_dir` property created by Config should default to 'php56'.
  {
    'name' => "Missing PHP: The root `php_dir` property should default to 'php56'.",
    'expect' => 'php56',
    'actual' => @tests.configs['required'].config['php_dir'],
  },

  ## ===> PHP 5

  # Condition;
  # - The root `php` value is '5'.
  #
  # Expected Outcome:
  # - The root `php_dir` value should match the config version.
  {
    'name' => "PHP 5: The root `php_dir` value should match the config version.",
    'expect' => 'php56',
    'actual' => @tests.configs['typical'].config['php_dir'],
  },

  ## ===> PHP 7

  # Condition;
  # - The root `php` value is '7'.
  #
  # Expected Outcome:
  # - The root `php_dir` value should match the config version.
  {
    'name' => "PHP 7: The root `php_dir` value should match the config version.",
    'expect' => 'php70',
    'actual' => @tests.configs['full'].config['php_dir'],
  },

])
