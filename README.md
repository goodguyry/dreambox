DreamBox
========

> Recreates the DreamHost shared hosting environment as a Vagrant box.

**Version 0.2.x contains breaking changes to the Vagrantfile setup. See [upgrading Dreambox][upgrading_dreambox] for more information.**

This project repo contains the code for [building the Dreambox base box][wiki_build]. To use Dreambox in your project, check out the ["Getting Started" section of the Wiki][getting_started].

## Package Versions

- Ubuntu - `12.04 LTS`
- PHP
    - `5.6.29`
    - `7.0.14`
- Apache - `2.2.31` (FastCGI)
- MySQL - `5.5.40`

_Python and Ruby environments are not set up. Contributions are welcome and appreciated._

See [the Wiki][getting_started] for additional setup options and documentation.

## References

- http://wiki.dreamhost.com/Supported_and_unsupported_technologies

[getting_started]: ../../wiki/Home
[wiki_build]: ../../wiki/Building-Dreambox
[upgrading_dreambox]: ../../wiki/Upgrading-Dreambox
