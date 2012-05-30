#class CollectdData
#  # tcpconns stats
#  def parse_plugin_tcpconns
#    [{
#      metric: "tcpconns.#{data['plugin_instance']}.#{data['type_instance']}",
#      value: data['values'][0]
#    }]
#  end
#end
