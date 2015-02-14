class CollectdData
  # disk partition stats
  def parse_plugin_generic
    metric = data['type']
    metric += ".#{data['type_instance']}" unless data['type_instance'].empty?
    [
     { metric: "#{metric}", value: data['values'][0] },
    ]
  end
end
