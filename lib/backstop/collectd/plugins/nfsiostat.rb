class CollectdData
  # nfs iostat
  def parse_plugin_nfsiostat
    [{
      metric: "#{data['plugin']}.#{data['plugin_instance']}.#{data['type_instance']}",
      value: data['values'][0]
    }]
  end
end
