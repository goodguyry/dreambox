#!/usr/bin/env ruby

# User
# Tests configutation values associated with sites' `user` and `group` properties

@tests.assertions.push(*[

  # Condition:
  # - A site has a user name declared.
  #
  # Expected Outcome:
  # - The site's user id should be a number greater than 500.
  {
    'name' => "UID: User ID should be greater than 500",
    'expect' => true,
    'actual' => @tests.the['typical'].config['sites']['typical-one']['uid'] > 500,
  },

  # Condition:
  # - A site has a user name declared.
  #
  # Expected Outcome:
  # - The site's user id should not equal that of another user.
  {
    'name' => "UID: The site's user id should not equal that of another user",
    'expect' => false,
    'actual' => @tests.the['typical'].config['sites']['typical-one']['uid'] == @tests.the['typical'].config['sites']['typical-two']['uid'],
  },

  # Condition:
  # - A site has a group name declared.
  #
  # Expected Outcome:
  # - The site's group id should be a number greater than 900.
  {
    'name' => "GID: Group ID should be greater than 900",
    'expect' => true,
    'actual' => @tests.the['typical'].config['sites']['typical-one']['gid'] > 900,
  },

  # Condition:
  # - A site has a group name declared.
  #
  # Expected Outcome:
  # - The site's group id should not equal that of another group
  {
    'name' => "GID: The site's group id should not equal that of another group",
    'expect' => false,
    'actual' => @tests.the['typical'].config['sites']['typical-one']['gid'] == @tests.the['typical'].config['sites']['typical-two']['gid'],
  },

  # Condition:
  # - A site has a group name declared.
  #
  # Expected Outcome:
  # - The site's group should successfully collected.
  {
    'name' => "Group: Group name should be the declared group",
    'expect' => 'example_group',
    'actual' => @tests.the['typical'].config['sites']['typical-one']['group'],
  },

  # Condition:
  # - A site has no group name declared.
  #
  # Expected Outcome:
  # - The site's group id should be a number greater than 900.
  {
    'name' => "GID: Group ID should be greater than 900",
    'expect' => true,
    'actual' => @tests.the['typical'].config['sites']['typical-two']['gid'] > 900 && @tests.the['typical'].config['sites']['typical-two']['gid'] != @tests.the['typical'].config['sites']['typical-one']['gid'],
  },

  # Condition:
  # - A site has no group name declared.
  #
  # Expected Outcome:
  # - The site's group should default to 'dreambox'.
  {
    'name' => "Group: Group name should default to `dreambox` when undeclared",
    'expect' => 'dreambox',
    'actual' => @tests.the['typical'].config['sites']['typical-two']['group'],
  },

  # Condition:
  # - Two users share a group name.
  #
  # Expected Outcome:
  # - The users' group ids should be equal.
  {
    'name' => "GID: Users for sites `full-one` and `full-two` should share a group ID",
    'expect' => true,
    'actual' => @tests.the['full'].config['sites']['full-two']['gid'] == @tests.the['full'].config['sites']['full-one']['gid'],
  },

])
