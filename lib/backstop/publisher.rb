module Backstop
  class Publisher
    attr_reader :connections, :api_key

    def initialize(urls, opts={})
      @connections = []
      @connections = urls.map { |u| URI.parse(u) }.map { |u| TCPSocket.new(u.host, u.port) }
      p @connections
      @api_key = opts[:api_key]
    end

    def metric_name(name)
      api_key ? "#{api_key}.#{name}" : name  
    end

    def publish(name, value, time=Time.now.to_i)
      c = connections.sample
      begin
        c.puts("#{metric_name(name)} #{value} #{time}")  
      rescue
        c.reopen(c)
        self.publish(name, value, time)
      end
    end
  end
end
