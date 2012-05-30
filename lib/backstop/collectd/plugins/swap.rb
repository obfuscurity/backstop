class CollectdData
  # swap stats
  def parse_plugin_swap
    [{
      metric: "swap.#{data['type_instance']}",
      value: data['values'][0]
    }]
  end
end
