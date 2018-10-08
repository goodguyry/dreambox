# Test configuration featuring multiple sites with full feature set
#
# The hosts list should contain only the first site's host,
# aliases and subdomains, because:
# - Only one site is missing an `ssl` setting, so the site
#   inherits the root SSL value.


# Test configuration featuring a typical setup
#
# The `hosts` property should contain only SSL-enabled hosts.

@tests.assertions.push(*[

  # Subdomain: Host should be correct based on parent site's domain
  {
    'name' => "Subdomain: Host should be correct based on parent site's domain",
    'expect' => 'help.example-two.dev',
    'actual' => @tests.the['full'].config['sites']['help.full-two']['host'],
  },

  # Subdomain (Alt syntax): Host should be correct even if parent has `www.` prefix
  {
    'name' => 'Subdomain (Alt syntax): Host should be correct even if parent has `www.` prefix',
    'expect' => 'app.example.dev',
    'actual' => @tests.the['full'].config['sites']['app.full-one']['host'],
  },

])
