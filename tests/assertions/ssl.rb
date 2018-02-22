#!/usr/bin/env ruby

# SSL
# Tests configutation values associated with SSL being enabled and disabled
#
# Notes:
# - The root `host` and `hosts` properties are only used in creating the SSL
#   certificate.

@tests.assertions.push(*[

  ## ===> Default (Missing)
  #
  # Overview:
  # - When the root SSL proprty is missing, the default fallback value
  #   should be `false`.
  ##

  # Conditions:
  # - The root `ssl` property is missing
  # - SSL is not enabled in the lone site declaration.
  #
  # Expected Outcome:
  # - The root `ssl_enabled` property created by Config should fall back
  #   to the default `false`.
  {
    'name' => 'Missing SSL: `ssl_enabled` should fall back to default `false` value.',
    'expect' => false,
    'actual' => @tests.the['required'].config['ssl_enabled'],
  },

  # Conditions:
  # - The root `ssl` property is missing
  # - SSL is not enabled in the lone site declaration.
  # - The root `host` property is missing in the config.
  #
  # Expected Outcome:
  # - The root `host` property should remain empty.
  {
    'name' => 'Missing SSL: The root `host` property should remain empty.',
    'expect' => nil,
    'actual' => @tests.the['required'].config['host'],
  },

  # Conditions:
  # - The root `ssl` property is missing
  # - SSL is not enabled in the lone site declaration.
  #
  # Expected Outcome:
  # - The root `hosts` property created by Config should be an empty string.
  {
    'name' => 'Missing SSL: The root `hosts` property should be an empty string.',
    'expect' => '',
    'actual' => @tests.the['required'].config['hosts'],
  },

  # Conditions:
  # - The root `ssl` property is missing
  # - SSL is not enabled in the lone site declaration.
  #
  # Expected Outcome:
  # - The site `ssl` property should inherit the root `ssl` value.
  {
    'name' => 'Missing SSL: The site `ssl` property should inherit the root `ssl` value.',
    'expect' => false,
    'actual' => @tests.the['required'].config['sites']['required']['ssl'],
  },

  # Conditions:
  # - The root `ssl` property is missing
  # - SSL is not enabled in the lone site declaration.
  # - The root `hosts` property is empty.
  #
  # Expected Outcome:
  # - The DNS Hosts file should not be created.
  {
    'name' => 'Missing SSL: The DNS Hosts file should not be created.',
    'expect' => false,
    'actual' => File.exist?(File.join(@assertions_dir, 'required.txt')),
  },

  ## ===> SSL Off
  #
  # Overview:
  # - When the root SSL proprty is declared, it should be inherited by
  #   all sites which don't declare an overriding `ssl` value.
  ##

  # Conditions:
  # - The root `ssl` value is `false`
  # - SSL is enabled in a site's declaration.
  #
  # Expected Outcome:
  # - The root `ssl_enabled` property created by Config should be `true`.
  {
    'name' => 'SSL Off: The root `ssl_enabled` property should be `true`.',
    'expect' => true, # See note in description for why
    'actual' => @tests.the['full'].config['ssl_enabled'],
  },

  # Conditions:
  # - The root `ssl` value is `false`
  # - The root `host` property is declared in the config.
  #
  # Expected Outcome:
  # - The root `host` property should remain unchanged.
  {
    'name' => 'SSL Off: The root `host` property should be the exact config value.',
    'expect' => 'main-host.dev',
    'actual' => @tests.the['full'].config['host'],
  },

  # Conditions:
  # - The root `ssl` value is `false`
  # - The first site's `ssl` property is not declared.
  #
  # Expected Outcome:
  # - The site should inherit the root `ssl` value.
  {
    'name' => 'SSL Off: The site should inherit the root `ssl` value.',
    'expect' => false,
    'actual' => @tests.the['full'].config['sites']['full-one']['ssl'],
  },

  # Conditions:
  # - The root `ssl` value is `false`
  # - The second site's `ssl` value is `true`.
  #
  # Expected Outcome:
  # - The site should not inherit the root `ssl` value.
  {
    'name' => 'SSL Off: The site should not inherit the root `ssl` value.',
    'expect' => true,
    'actual' => @tests.the['full'].config['sites']['full-two']['ssl'],
  },

  # Conditions:
  # - The root `ssl` value is `false`
  # - The second site's `ssl` value is `true`.
  #
  # Expected Outcome:
  # - The second site's subdomains should inherit the `true` value.
  {
    'name' => "SSL Off: The site's subdomains should inherit the site's `ssl` value (enabled).",
    'expect' => true,
    'actual' => @tests.the['full'].config['sites']['help.full-two']['ssl'],
  },

  # Conditions:
  # - The root `ssl` value is `false`
  # - The first site's `ssl` value is inherited as `false` from the
  #   root `ssl` property.
  #
  # Expected Outcome:
  # - The site's subdomains should inherit the `false` value as well.
  {
    'name' => "SSL Off: The site's subdomains should inherit the site's `ssl` value (disabled).",
    'expect' => false,
    'actual' => @tests.the['full'].config['sites']['app.full-one']['ssl'],
  },

  # Conditions:
  # - The root `ssl` value is `false`
  # - The second site's `ssl` value is `true`.
  # - The root `host` property is set.
  #
  # Expected Outcome:
  # - All of the SSL-enabled site's host and alias values should be added
  #   to the root `hosts` property by Config as a string.
  {
    'name' => 'SSL Off: The `hosts` property should contain all SSL-enabled hosts.',
    'expect' => 'DNS.1 = example-two.dev\nDNS.2 = www.example-two.dev\nDNS.3 = help.example-two.dev',
    'actual' => @tests.the['full'].config['hosts'],
  },

  ## ===> SSL On
  #
  # Overview:
  # - When the root SSL proprty is declared, it should be inherited by
  #   all sites which don't declare an overriding `ssl` value.
  ##

  # Conditions:
  # - The root `ssl` value is `true`
  # - SSL is enabled in the root `ssl` property
  # - SSL is not overridden in all of the sites
  #
  # Expected Outcome:
  # - The root `ssl_enabled` property created by Config should be `true`.
  {
    'name' => 'SSL On: the root `ssl_enabled` property should be true.',
    'expect' => true,
    'actual' => @tests.the['typical'].config['ssl_enabled'],
  },

  # Conditions:
  # - The root `ssl` value is `true`
  # - The first site's `ssl` property is not declared.
  #
  # Expected Outcome:
  # - The site should inherit the root `ssl` value.
  {
    'name' => "SSL On: The site's undeclared `ssl` value should inherit from the root.",
    'expect' => true,
    'actual' => @tests.the['typical'].config['sites']['typical-one']['ssl'],
  },

  # Conditions:
  # - The root `ssl` value is `true`
  # - The second site's `ssl` value is `false`.
  #
  # Expected Outcome:
  # - The site should not inherit the root `ssl` value.
  {
    'name' => 'SSL On: The site should not inherit the root `ssl` value.',
    'expect' => false,
    'actual' => @tests.the['typical'].config['sites']['typical-two']['ssl'],
  },

  # Conditions:
  # - The root `ssl` value is `true`
  # - The first site's `ssl` property is undeclared, so the value was inherited
  #   from the root.
  # - The root `host` property is undeclared, so the property took the site's
  #   `host` value.
  # - The first site's alias values should be added to the root `hosts`
  #   property by Config
  #
  # Expected Outcome:
  # - The hosts string should contain the SSL-enabled site's aliases.
  {
    'name' => "SSL On: The DNS Hosts file should contain the SSL-enabled site's aliases.",
    'expect' => 'DNS.1 = example.dev\nDNS.2 = www.example.dev\nDNS.3 = *.example.dev',
    'actual' => @tests.the['typical'].config['hosts'],
  },

])
