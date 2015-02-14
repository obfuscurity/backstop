class CollectdData
  # disk partition stats
  def parse_plugin_generic
    [
     { metric: "#{data['type']}.#{data['type_instance']}", value: data['values'][0] },
    ]
  end
end
