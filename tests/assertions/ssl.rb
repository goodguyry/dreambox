#!/usr/bin/env ruby

# SSL
# Tests configutation values associated with SSL being enabled and disabled
#
# Notes:
# - The `host` properties are used in creating the SSL certificate.

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
  # - The root `ssl_enabled` property should fall back  to the default `false`.
  {
    'name' => 'Missing SSL: `ssl_enabled` should fall back to default `false` value.',
    'expect' => false,
    'actual' => @tests.the['required'].config['ssl_enabled'],
  },

  # Conditions:
  # - The root `ssl` property is missing
  # - SSL is not enabled in the lone site declaration.
  #
  # Expected Outcome:
  # - The root `san_list` property should be an empty string.
  {
    'name' => 'Missing SSL: The root `san_list` property should be an empty string.',
    'expect' => '',
    'actual' => @tests.the['required'].config['san_list'],
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
  # - The root `ssl_enabled` property should be `true`.
  {
    'name' => 'SSL Off: The root `ssl_enabled` property should be `true`.',
    'expect' => true, # See note in description for why
    'actual' => @tests.the['full'].config['ssl_enabled'],
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
  #
  # Expected Outcome:
  # - The `san_list` property should contain all SSL-enabled hosts in
  #   SubjectAlternateName format (DNS.<n> = <hostname>).
  {
    'name' => 'SSL Off: The `san_list` property should contain all SSL-enabled hosts.',
    'expect' => 'DNS.1 = example-two.dev\nDNS.2 = www.example-two.dev\nDNS.3 = help.example-two.dev',
    'actual' => @tests.the['full'].config['san_list'],
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
  # - The root `ssl_enabled` property should be `true`.
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
  # - The first site's alias values should be added to the root `san_list`
  #   property by Config
  #
  # Expected Outcome:
  # - The `san_list` property should contain all SSL-enabled hosts in
  #   SubjectAlternateName format (DNS.<n> = <hostname>).
  {
    'name' => "SSL On: The `san_list` property should contain all SSL-enabled hosts.",
    'expect' => 'DNS.1 = example.dev\nDNS.2 = www.example.dev\nDNS.3 = *.example.dev',
    'actual' => @tests.the['typical'].config['san_list'],
  },

])
