class CollectdData
  # system load
  def parse_plugin_load
    [
     { metric: 'load.1m', value: data['values'][0] },
     { metric: 'load.5m', value: data['values'][1] },
     { metric: 'load.15m', value: data['values'][2] }
    ]
  end
end
