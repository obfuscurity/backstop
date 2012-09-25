class CollectdData
  # conntrack stats
  def parse_plugin_conntrack
    [{
      metric: 'conntrack.connections',
      value: data['values'][0]
    }]
  end
end
