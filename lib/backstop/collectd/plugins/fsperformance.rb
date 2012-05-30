class CollectdData
  # file system performance
  def parse_plugin_fsperformance
    [{
      metric: "#{data['plugin']}.#{data['plugin_instance']}.#{data['type_instance']}",
      value: data['values'][0]
    }]
  end
end
