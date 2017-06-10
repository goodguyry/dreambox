# Test configuration featuring multiple sites with full feature set
#
# The hosts list should contain only the first site's host,
# aliases and subdomains, because:
# - Only one site is missing an `ssl` setting, so the site
#   inherits the root SSL value.
# - There is a host declared on the config root `host`
#   property, so the site's host doesn't need to be repurposed
#   as the root host.


# Test configuration featuring a typical setup
#
# The root host inherit the first SSL-enabled host declared. The
# hosts list should contain only SSL-enabled aliases.

@tests.assertions.push(*[

  # Subdomain: Host should be correct based on parent site's domain
  {
    'name' => "Subdomain: Host should be correct based on parent site's domain",
    'expect' => 'help.example-two.dev',
    'actual' => @tests.configs['full'].config['sites']['help.full-two']['host'],
  },

  # Subdomain (Alt syntax): Host should be correct even if parent has `www.` prefix
  {
    'name' => 'Subdomain (Alt syntax): Host should be correct even if parent has `www.` prefix',
    'expect' => 'app.example.dev',
    'actual' => @tests.configs['full'].config['sites']['app.full-one']['host'],
  },

])
