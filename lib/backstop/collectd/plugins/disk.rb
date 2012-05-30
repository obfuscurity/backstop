class CollectdData
  # disk volume stats
  def parse_plugin_disk
    [
     { metric: "disk.#{data['plugin_instance']}.#{data['type']}.write", value: data['values'][0] },
     { metric: "disk.#{data['plugin_instance']}.#{data['type']}.read", value: data['values'][1] }
    ]
  end
end
