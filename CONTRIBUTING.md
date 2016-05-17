DreamBox is an open source project. It is licensed using the [GNU General Public License v3.0](http://www.gnu.org/licenses/gpl-3.0.txt). I appreciate any and all pull requests and bug reports. Please adhere to the following for bugs and patches:

1. File a bug at https://github.com/goodguyry/dreambox/issues (if there isn’t one already).
2. Please start a discussion beforehand for any large patches and pull requests.
3. Make sure to fully document any patches and pull requests, regarding what it achieves and why it is necessary.

If you're adding software:

1. Please do your best to make sure the version matches the current version used by DreamHost.
2. Please create a script (such as what exists in [/src](src)) for configuration and installation, including building a Debian package (using `checkinstall`) and `zip`ing it to /pkg.
3. Please add any necessary post-install setup to [package-setup.sh](scripts/package-setup.sh)

Thanks!
