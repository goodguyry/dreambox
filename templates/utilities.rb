class String
  def red;     "\e[31m#{self}\e[0m" end
  def green;   "\e[32m#{self}\e[0m" end
  def yellow;  "\e[33m#{self}\e[0m" end
  def bold;    "\e[1m#{self}\e[22m" end
end

module Helpers
  def trim_ending_slash(str)
    ('/' == str[-1..-1]) ? str[0..-2] : str
  end

  def trim_beginning_slash(str)
    ('/' == str[0..0]) ? str[1..-1] : str
  end

  def trim_slashes(str)
    trim_ending_slash(trim_beginning_slash(str))
  end

  def add_item_to_root(item, key)
    @config[key] = @config.fetch(key).push(item) unless @config.fetch(key).include?(item)
  end

  def remove_www(host)
    ('www' == host[0..2]) ? host[4..-1] : host
  end

  def handle_error(e, message)
    puts "#{e.class.name}: #{message}.".red
    puts "See 'Getting Started': https://github.com/goodguyry/dreambox/wiki".yellow
    trace = e.backtrace.select { |bt| bt.match(File.expand_path(Dir.pwd)) }
    puts trace if ! defined?(@raw) || (@raw.key?('debug') && true == @raw.fetch('debug'))
    abort
  end

  def print_debug_info(config, file)
    puts ''
    puts "===> Dreambox Debug:".bold.yellow

    printf "%-24s %s\n", 'Config File', file
    printf "%-24s %s\n", 'PHP Version', config['php'].to_s.split(//).join('.')
    printf "%-24s %s\n", 'SSL Enabled', config['ssl_enabled']
    host_list = config['san_list'].split('\n')
    host_list.each.with_index do |host, index|
      if (0 == index)
        printf "%-24s %s\n", 'Hosts', host
      else
        printf "%-24s %s\n", '', host
      end
    end

    puts ''

    config['sites'].each do |site, items|
      puts "===> Site: #{site}:".bold.yellow
      printf "%-24s %s\n", 'Host', items['host'] if items['host']
      printf "%-24s %s\n", 'User', items['user'] if items['user']
      printf "%-24s %s\n", 'Group', items['group'] if (items['group'] != 'dreambox')
      printf "%-24s %s\n", 'Document Root', items['document_root'] if items['document_root']
      printf "%-24s %s\n", 'Local Sync Folder', items['sync'] if items['sync']
      printf "%-24s %s\n", 'PHP Version', items['php'].to_s.split(//).join('.') if items['php']
      printf "%-24s %s\n", 'SSL Enabled', items['ssl']
      printf "%-24s %s\n", 'Aliases', items['aliases'].split(' ').join(', ') if items['aliases']
      printf "%-24s %s\n", 'Virtual Host Config', items['vhost_file'] if items['vhost_file']
      puts ''
    end
    puts ''
  end
end
