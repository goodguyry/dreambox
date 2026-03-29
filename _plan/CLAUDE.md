# Upgrade Dreambox server configuration

This project was conceived and written many years ago. The last meaningful changes are from October 2018. It has been essentially abandoned since.

I want to move away from DreamHost's NDN repositories. I want to update it to match the server configuration outlined in phpinfo.html and apache2-debian-default-page.html. There is a good starting point in provision.sh.

Create a phased approach for upgrading this project. All existing features should be supported, with the PHP version options updated to 8.2, 8.3, 8.4, and 8.5. Write the plan to a file in this directory.

I want to update Ruby tests to a widely-used and trusted testing framework

Some possible enhancements after the upgrade:
* Ensure mail packages are installed and configured, including Mailcatcher
* Improve documentation throughout
