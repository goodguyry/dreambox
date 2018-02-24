DreamBox
========

> Recreates the DreamHost shared hosting environment as a Vagrant box.

**Version 0.2.x contains breaking changes to the Vagrantfile setup. See [upgrading Dreambox][upgrading_dreambox] for more information.**

This project repo contains the code for [building the Dreambox base box][wiki_build]. To use Dreambox in your project, check out the ["Getting Started" section of the Wiki][getting_started].

## Package Versions

Ubuntu `14.04 LTS`

| Package           | Version    |
| ------------------|------------|
| ndn-php56         | 5.6.33-1   |
| ndn-php70         | 7.0.27-1   |
| ndn-php71         | 7.1.13-1   |
| ndn-apache22      | 2.2.31-5   |
| mysql-server-5.6  | 5.6.33     |

_Python and Ruby environments are not set up. Contributions are welcome and appreciated._

See [the Wiki][getting_started] for additional setup options and documentation.

## References

- https://help.dreamhost.com/hc/en-us/articles/217141627-Supported-and-unsupported-technologies

[getting_started]: ../../wiki/Home
[wiki_build]: ../../wiki/Building-Dreambox
[upgrading_dreambox]: ../../wiki/Upgrading-Dreambox
