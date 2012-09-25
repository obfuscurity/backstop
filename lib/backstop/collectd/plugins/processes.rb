class CollectdData
  def parse_plugin_processes
    # matches specific proceses
    if !data['plugin_instance'].empty?
      ps_value_map = {
        'ps_count' => ['num_proc', 'num_thread'],
        'ps_disk_ops' => ['read', 'write'],
        'ps_disk_octets' => ['read', 'write'],
        'ps_pagefaults' => ['minor', 'major'],
        'ps_cputime' => ['user', 'system']
      }
  
      if (map = ps_value_map[data['type']])
        [
          {
            metric: "#{data['plugin']}.#{data['plugin_instance']}.#{data['type']}.#{map[0]}",
            value: data['values'][0]
          },
          {
            metric: "#{data['plugin']}.#{data['plugin_instance']}.#{data['type']}.#{map[1]}",
            value: data['values'][1]
          }
        ]
      else
        [
          {
            metric: "#{data['plugin']}.#{data['plugin_instance']}.#{data['type']}",
            value: data['values'][0]
          }
        ]
      end
    elsif data['type_instance'].empty?
      # matches fork_rate
      [
        {
          metric: "processes.#{data['type']}",
          value: data['values'][0]
        }
      ]
    else
      # everything else in ps_state
      [
        {
          metric: "processes.#{data['type_instance']}",
          value: data['values'][0]
        }
      ]
    end
  end
end
