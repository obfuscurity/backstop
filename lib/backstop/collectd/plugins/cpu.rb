class CollectdData
  # cpu stats
  def parse_plugin_cpu
    [{
      metric: "cpu.#{data['plugin_instance']}.#{data['type_instance']}",
      value: data['values'][0]
    }]
  end
end
