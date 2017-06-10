#!/usr/bin/env ruby

# Paths
# Tests configutation values outputting file and directory paths


@tests.assertions.push(*[

  # Expected Outcome:
  # - The site's `root_path` property created by Config should have the
  #   correct path
  {
    'name' => "Paths: The site's `root_path` property should have the correct path.",
    'expect' => '/home/user-two/example-two.com',
    'actual' => @tests.configs['full'].config['sites']['full-two']['root_path'],
  },

  # Conditions:
  # - The site's `username` property has a valid String value.
  # - The site's `root` property has a valid String value.
  # - The site's `public` property has a valid String value.
  #
  # Expected Outcome:
  # - The site's `root_path` property created by Config should have the
  #   correct path with a public folder.
  {
    'name' => "Paths: The site's `root_path` property should have the correct path with a public folder.",
    'expect' => '/home/user/example.com/public',
    'actual' => @tests.configs['full'].config['sites']['full-one']['root_path'],
  },

  # Conditions:
  # - The site's `username` property has a valid String value.
  # - The site's `root` property has a valid String value.
  # - The site has a valid subdomain delcaration
  #
  # Expected Outcome:
  # - The subdomain's `root_path` property created by Config should have the
  #   correct path.
  {
    'name' => "Paths: The subdomain's `root_path` property created by Config should have the correct path.",
    'expect' => '/home/user-two/example-two.com/app/help',
    'actual' => @tests.configs['full'].config['sites']['help.full-two']['root_path'],
  },

  # Conditions:
  # - The site's `username` property has a valid String value.
  # - The site's `root` property has a valid String value.
  # - The site has a valid subdomain delcaration
  # - The parent site's `public` property has a valid String value.
  #
  # Expected Outcome:
  # - The subdomain's `root_path` property created by Config should have the
  #   correct path with a public folder.
  #
  # We can't always assume subdomains will be nested in the public folder, so
  # the public folder path is required if it needs to be included in the
  # subdomain root path.
  {
    'name' => "Paths: The subdomain's `root_path` property created by Config should have the correct path with a public folder.",
    'expect' => '/home/user/example.com/app',
    'actual' => @tests.configs['full'].config['sites']['app.full-one']['root_path'],
  },

  # Condition:
  # - The site has a valid String name
  #
  # Expected Outcome:
  # - The vhost.conf filename should be based on site's name
  {
    'name' => "Paths: The vhost.conf filename should be based on site's name.",
    'expect' => '/usr/local/apache2/conf/vhosts/full-one.conf',
    'actual' => @tests.configs['full'].config['sites']['full-one']['vhost_file'],
  },

  # Condition:
  # - The site has a valid String name
  # - The site has a valid subdomain delcaration
  #
  # Expected Outcome:
  # - The vhost.conf filename should be based on site's subdomain and name joined by a dot.
  {
    'name' => "Paths: The vhost.conf filename should be based on site's subdomain and name joined by a dot.",
    'expect' => '/usr/local/apache2/conf/vhosts/app.full-one.conf',
    'actual' => @tests.configs['full'].config['sites']['app.full-one']['vhost_file'],
  },

  # @TODO Paths: DNS Hosts File path should be correct
  {},

])
