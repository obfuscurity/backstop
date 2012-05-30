class CollectdData
  # droid stats
  def parse_plugin_droid
    [{
      metric: "droid.#{data['type_instance']}",
      value: data['values'][0]
    }]
  end
end
