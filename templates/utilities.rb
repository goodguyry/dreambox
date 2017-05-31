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
  puts "     Config File:   #{file}".bold
  puts "     Box Name:      #{config['name']}".bold
  if config['host'].kind_of? String then
    puts "     Host:          #{config['host']}".bold
  end
  puts "     PHP Version:   #{config['php']}".bold
  puts "     PHP Dir:       #{config['php_dir']}".bold
  puts "     SSL Enabled:   #{config['ssl_enabled']}".bold
  if 0 < "#{config['hosts']}".length then
    puts "     Hosts:         #{config['hosts']}".bold
  end
  dns_hosts_file = File.join(File.dirname(__FILE__), 'dns-hosts.txt')
  if File.exist?(dns_hosts_file) then
    puts "     DNS Hosts File:  #{dns_hosts_file}".bold
  end
  puts ''
  config['sites'].each do |site, items|
    if items['is_subdomain'] then
      puts "===> #{site}: is_subdomain  #{items['is_subdomain']}".bold
    end
    puts "===> #{site}: username     #{items['username']}".bold
    puts "     #{site}: root_path    #{items['root_path']}".bold
    puts "     #{site}: root         #{items['root']}".bold
    puts "     #{site}: local_root   #{items['local_root']}".bold
    if items['ssl'] then
      puts "     #{site}: ssl          #{items['ssl']}".bold
    end
    puts "     #{site}: aliases      #{items['aliases']}".bold
    puts "     #{site}: box_name     #{items['box_name']}".bold
    puts "     #{site}: host         #{items['host']}".bold
    puts "     #{site}: vhost_file    #{items['vhost_file']}".bold
    puts ''
  end
  puts ''
end