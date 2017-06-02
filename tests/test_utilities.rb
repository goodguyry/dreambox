@tests.assertions.push(*[
  # Utility function
  #
  # trim_slashes
  {
    'name' => 'trim_slashes',
    'expect' => 'path/to/directory',
    'actual' => trim_slashes('/path/to/directory/'),
  },

  # Utility function
  #
  # trim_slashes
  # Path has no beginning or ending slash
  {
    'name' => 'trim_slashes - no slashes',
    'expect' => 'path/to/directory',
    'actual' => trim_slashes('path/to/directory'),
  },

  # Utility function
  #
  # trim_ending_slash
  {
    'name' => 'trim_ending_slash',
    'expect' => '/path/to/directory',
    'actual' => trim_ending_slash('/path/to/directory/'),
  },

  # Utility function
  #
  # trim_ending_slash
  # Path has no ending slash
  {
    'name' => 'trim_ending_slash - no ending slash',
    'expect' => '/path/to/directory',
    'actual' => trim_ending_slash('/path/to/directory'),
  },

  # Utility function
  #
  # trim_beginning_slash
  # Path has no beginning slash
  {
    'name' => 'trim_beginning_slash - no beginning slash',
    'expect' => 'path/to/directory/',
    'actual' => trim_beginning_slash('path/to/directory/'),
  },
])
