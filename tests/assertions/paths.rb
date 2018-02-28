#!/usr/bin/env ruby

# Paths
# Tests configutation values outputting file and directory paths


@tests.assertions.push(*[

  # Expected Outcome:
  # - The site's `document_root` property created by Config should have the
  #   correct path
  {
    'name' => "Paths: The site's `document_root` property should have the correct path.",
    'expect' => '/home/user-two/example-two.com',
    'actual' => @tests.the['full'].config['sites']['full-two']['document_root'],
  },

  # Conditions:
  # - The site's `user` property has a valid String value.
  # - The site's `root` property has a valid String value.
  # - The site's `public` property has a valid String value.
  #
  # Expected Outcome:
  # - The site's `document_root` property created by Config should have the
  #   correct path with a public folder.
  {
    'name' => "Paths: The site's `document_root` property should have the correct path with a public folder.",
    'expect' => '/home/user/example.com/public',
    'actual' => @tests.the['full'].config['sites']['full-one']['document_root'],
  },

  # Conditions:
  # - The site's `user` property has a valid String value.
  # - The site's `root` property has a valid String value.
  # - The site's `public` property has a valid String value.
  #
  # Expected Outcome:
  # - The site's `sync_destination` property created by Config should unaffected by the public folder.
  {
    'name' => "Paths: The site's `sync_destination` property should be unaffected by the public folder.",
    'expect' => '/home/user/example.com',
    'actual' => @tests.the['full'].config['sites']['full-one']['sync_destination'],
  },

  # Conditions:
  # - The site's `user` property has a valid String value.
  # - The site's `root` property has a valid String value.
  # - The site has a valid subdomain delcaration
  #
  # Expected Outcome:
  # - The subdomain's `document_root` property created by Config should have the
  #   correct path.
  {
    'name' => "Paths: The subdomain's `document_root` property created by Config should have the correct path.",
    'expect' => '/home/user-two/example-two.com/app/help',
    'actual' => @tests.the['full'].config['sites']['help.full-two']['document_root'],
  },

  # Conditions:
  # - The site's `user` property has a valid String value.
  # - The site's `root` property has a valid String value.
  # - The site has a valid subdomain delcaration
  # - The parent site's `public` property has a valid String value.
  #
  # Expected Outcome:
  # - The subdomain's `document_root` property created by Config should have the
  #   correct path with a public folder.
  #
  # Additional Information:
  # - We can't always assume subdomains will be nested in the public folder, so
  #   the public folder path is required if it needs to be included in the
  #   subdomain root path.
  {
    'name' => "Paths: The subdomain's `document_root` property created by Config should have the correct path with a public folder.",
    'expect' => '/home/user/example.com/public/app',
    'actual' => @tests.the['full'].config['sites']['app.full-one']['document_root'],
  },

  # Condition:
  # - The site has a valid String name
  #
  # Expected Outcome:
  # - The vhost.conf filename should be based on site's name
  {
    'name' => "Paths: The vhost.conf filename should be based on site's name.",
    'expect' => '/usr/local/dh/apache2/apache2-dreambox/etc/vhosts/full-one.conf',
    'actual' => @tests.the['full'].config['sites']['full-one']['vhost_file'],
  },

  # Condition:
  # - The site has a valid String name
  # - The site has a valid subdomain delcaration
  #
  # Expected Outcome:
  # - The vhost.conf filename should be based on site's subdomain and name joined by a dot.
  {
    'name' => "Paths: The vhost.conf filename should be based on site's subdomain and name joined by a dot.",
    'expect' => '/usr/local/dh/apache2/apache2-dreambox/etc/vhosts/app.full-one.conf',
    'actual' => @tests.the['full'].config['sites']['app.full-one']['vhost_file'],
  },

])
