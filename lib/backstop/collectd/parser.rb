require 'json'

class CollectdData
  
  # ALL PLUGIN CHECKS ARE EXPECTED TO RETURN AN ARRAY OF HASHES OR AN EMPTY ARRAY
  Dir[File.dirname(__FILE__) + '/plugins/*.rb'].each do |file|
    f = File.basename(file).gsub(/\.rb/, '')
    require "backstop/collectd/plugins/#{f}"
  end

  attr_accessor :data

  def initialize(data)
    self.data = data
  end

  def parse
    base = parse_base
    plugin = parse_plugin
    plugin.map {|p| p.merge base}
  end

  # extract cloud, slot, and id
  def parse_base
    hostname = data['host'].gsub('DOT','.').gsub('DASH', '-')
    parts = hostname.split('.')
    id = parts.last
    slot = parts[-2]
    cloud = parts.first(parts.size-2).join('.')
    measure_period = (data['interval'] || 10).to_i
    {id: id, slot: slot, cloud: cloud, measure_period: measure_period, measure_time: data['time']}
  end

  # extract the juicy bits, but do it dynamically
  # we check for the existence of a predefined method called parse_plugin_PLUGIN
  # if it exists, we dispatch.  If it doesn't, we return an empty array
  def parse_plugin
    plugin = data['plugin']
    method = "parse_plugin_#{plugin}".to_sym
    unless self.respond_to? method
      method = :parse_plugin_generic
    end
    send(method)
  end

end
