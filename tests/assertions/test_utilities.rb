@tests.assertions.push(*[
  # Beginning and ending slashes should be removed
  {
    'name' => 'trim_slashes: Beginning and ending slashes should be removed.',
    'expect' => 'path/to/directory',
    'actual' => trim_slashes('/path/to/directory/'),
  },

  # String should not be altered
  {
    'name' => 'trim_slashes: String should not be altered.',
    'expect' => 'path/to/directory',
    'actual' => trim_slashes('path/to/directory'),
  },

  # Ending slash should be removed
  {
    'name' => 'trim_ending_slash: Ending slash should be removed.',
    'expect' => '/path/to/directory',
    'actual' => trim_ending_slash('/path/to/directory/'),
  },

  # String should not be altered
  {
    'name' => 'trim_ending_slash: String should not be altered.',
    'expect' => '/path/to/directory',
    'actual' => trim_ending_slash('/path/to/directory'),
  },

  # Beginning slash should be removed
  {
    'name' => 'trim_beginning_slash: Beginning slash should be removed.',
    'expect' => 'path/to/directory/',
    'actual' => trim_beginning_slash('/path/to/directory/'),
  },

  # String should not be altered
  {
    'name' => 'trim_beginning_slash: String should not be altered.',
    'expect' => 'path/to/directory/',
    'actual' => trim_beginning_slash('path/to/directory/'),
  },
])
