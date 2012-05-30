class CollectdData
  # disk partition stats
  def parse_plugin_df
    [
     { metric: "df.#{data['type_instance']}.used", value: data['values'][0] },
     { metric: "df.#{data['type_instance']}.free", value: data['values'][1] }
    ]
  end
end
