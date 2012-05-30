class CollectdData
  # interface stats
  def parse_plugin_interface
    [
     { metric: "net.#{data['type_instance']}.#{data['type']}.in", value: data['values'][0] },
     { metric: "net.#{data['type_instance']}.#{data['type']}.out",value: data['values'][1] }
    ]
  end
end
