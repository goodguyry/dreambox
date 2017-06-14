# Helper class for formatting message text
class String
  def red;     "\e[31m#{ self }\e[0m" end
  def green;   "\e[32m#{ self }\e[0m" end
  def yellow;  "\e[33m#{ self }\e[0m" end
  def bold;    "\e[1m#{ self }\e[22m" end
end

# Print debug info
def print_debug_info(config, file)
  puts ''
  puts "===> Dreambox Debug:".bold.yellow

  printf "%-20s %s\n", 'Config File', file
  printf "%-20s %s\n", 'Box Name', config['name']
  printf "%-20s %s\n", 'Host', config['host'] if config['host'].kind_of? String
  printf "%-20s %s\n", 'PHP Version', config['php']
  printf "%-20s %s\n", 'PHP Dir', config['php_dir']
  printf "%-20s %s\n", 'SSL Enabled', config['ssl_enabled']
  printf "%-20s %s\n", 'Hosts', config['hosts'] if 0 < "#{ config['hosts'] }".length
  dns_hosts_file = File.join( File.dirname( __FILE__ ), 'dns-hosts.txt' )
  printf "%-20s %s\n", 'DNS Hosts File', dns_hosts_file if File.exist?( dns_hosts_file )

  puts ''

  config['sites'].each do |site, items|
    puts "===> #{ site }:".bold.yellow
    printf "%-20s %s\n", 'is_subdomain', items['is_subdomain'] if items['is_subdomain']
    printf "%-20s %s\n", 'username', items['username']
    printf "%-20s %s\n", 'root_path', items['root_path']
    printf "%-20s %s\n", 'root', items['root']
    printf "%-20s %s\n", 'local_root', items['local_root']
    printf "%-20s %s\n", 'ssl', items['ssl'] if items['ssl']
    printf "%-20s %s\n", 'aliases', items['aliases']
    printf "%-20s %s\n", 'box_name', items['box_name']
    printf "%-20s %s\n", 'host', items['host']
    printf "%-20s %s\n", 'vhost_file', items['vhost_file']
    puts ''
  end
  puts ''
end
