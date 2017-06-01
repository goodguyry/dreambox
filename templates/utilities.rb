# Helper class for formatting message text
class String
  def red;     "\e[31m#{self}\e[0m" end
  def green;   "\e[32m#{self}\e[0m" end
  def yellow;  "\e[33m#{self}\e[0m" end
  def bold;    "\e[1m#{self}\e[22m" end
end

# Helper function for printing error messages
def print_error(message, fatal)
  prefix = '===> Dreambox config'
  if (fatal) then
    puts "#{prefix}: #{message}".bold.red
    abort "     See 'Getting Started': https://github.com/goodguyry/dreambox/wiki".bold.yellow
  else
    puts "#{prefix}: #{message}".bold.yellow
  end
end

# Helper functions for trimming unwanted slashes
def trim_slashes(str)
  return trim_ending_slash(trim_beginning_slash(str))
end

def trim_ending_slash(str)
  return ('/' == str[-1..-1]) ? str[0..-2] : str
end

def trim_beginning_slash(str)
  return ('/' == str[0..0]) ? str[1..-1] : str
end

# Print debug info
def print_debug_info(config, file)
  puts ''
  puts "===> Dreambox Debug:".bold.yellow
  printf "%-20s %s\n", 'Config File', file
  printf "%-20s %s\n", 'Box Name', config['name']
  if config['host'].kind_of? String then
    printf "%-20s %s\n", 'Host', config['host']
  end
  printf "%-20s %s\n", 'PHP Version', config['php']
  printf "%-20s %s\n", 'PHP Dir', config['php_dir']
  printf "%-20s %s\n", 'SSL Enabled', config['ssl_enabled']
  if 0 < "#{config['hosts']}".length then
    printf "%-20s %s\n", 'Hosts', config['hosts']
  end
  dns_hosts_file = File.join(File.dirname(__FILE__), 'dns-hosts.txt')
  if File.exist?(dns_hosts_file) then
    printf "%-20s %s\n", 'DNS Hosts File', dns_hosts_file
  end
  puts ''
  config['sites'].each do |site, items|
    puts "===> #{site}:".bold.yellow
    if items['is_subdomain'] then
      printf "%-20s %s\n", 'is_subdomain', items['is_subdomain']
    end
    printf "%-20s %s\n", 'username', items['username']
    printf "%-20s %s\n", 'root_path', items['root_path']
    printf "%-20s %s\n", 'root', items['root']
    printf "%-20s %s\n", 'local_root', items['local_root']
    if items['ssl'] then
      printf "%-20s %s\n", 'ssl', items['ssl']
    end
    printf "%-20s %s\n", 'aliases', items['aliases']
    printf "%-20s %s\n", 'box_name', items['box_name']
    printf "%-20s %s\n", 'host', items['host']
    printf "%-20s %s\n", 'vhost_file', items['vhost_file']
    puts ''
  end
  puts ''
end
