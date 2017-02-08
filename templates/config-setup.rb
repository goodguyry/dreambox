#!/usr/bin/env ruby
require 'yaml'

module Config
  vagrant_dir = File.expand_path(Dir.pwd)

  if defined? vm_config_file
    vm_config_file_path = File.join(vagrant_dir, vm_config_file)
  else
    vm_config_file_path = File.join(vagrant_dir, 'vm-config.yml')
  end

  config_file_message = "Dreambox config file: #{vm_config_file_path}"
  puts "\e[32m\e[1m#{config_file_message}\e[0m"

  if File.file?(vm_config_file_path) then
    VM_CONFIG = YAML.load_file(vm_config_file_path)
  end

  VM_CONFIG['sites'].each do |site, items|
    if ! items.kind_of? Hash then
        items = Hash.new
    end

    defaults = Hash.new
    defaults['local_root'] = 'web'
    defaults['ssl_enabled'] = false

    items['root_path'] = "/home/#{items['username']}/#{items['web_root']}"

    if ! items['config'].kind_of? Array then
        items['config'] = Array.new
    end

    items['config'].each do |conf|
      case conf
      when 'ssl'
        items['ssl_enabled'] = true
        items['ssl_name'] = items['host']
      end
    end

    VM_CONFIG['sites'][site].delete('config')
    VM_CONFIG['sites'][site] = defaults.merge(items)
  end
end
