# Helper class for formatting message text
class String
  def red;     "\e[31m#{self}\e[0m" end
  def green;   "\e[32m#{self}\e[0m" end
  def yellow;  "\e[33m#{self}\e[0m" end
  def bold;    "\e[1m#{self}\e[22m" end
end

# Helper function for printing error messages
def print_error(message)
   puts "===> Dreambox config: #{message}".bold.red
   abort "     See 'Getting Started': https://github.com/goodguyry/dreambox/wiki".bold.yellow
end

# Print debug info
def print_debug_info(config, file)
  puts ''
  puts "===> Dreambox Debug:".bold.yellow
  puts "     Config File:   #{file}".bold
  puts "     Box Name:      #{config['name']}".bold
  puts "     PHP Version:   #{config['php']}".bold
  puts "     SSL Enabled:   #{config['ssl_enabled']}".bold
  if 0 < "#{config['hosts']}".length then
    puts "     Hosts:         #{config['hosts']}".bold
  end
  puts ''
  config['sites'].each do |site, items|
    puts "===> #{site}: username     #{items['username']}".bold
    puts "     #{site}: root_path    #{items['root_path']}".bold
    puts "     #{site}: root         #{items['root']}".bold
    puts "     #{site}: local_root   #{items['local_root']}".bold
    if 0 < "#{items['ssl']}".length then
      puts "     #{site}: ssl          #{items['ssl']}".bold
    end
    if 0 < "#{items['aliases']}".length then
      puts "     #{site}: aliases      #{items['aliases']}".bold
    end
    puts "     #{site}: box_name     #{items['box_name']}".bold
    puts "     #{site}: host         #{items['host']}".bold
    puts ''
  end
  puts ''
end
