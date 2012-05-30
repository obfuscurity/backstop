class CollectdData
  # memory stats
  def parse_plugin_memory
    [{
      metric: "memory.#{data['type_instance']}",
      value: data['values'][0]
    }]
  end
end
