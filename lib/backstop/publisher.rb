module Backstop
  class Publisher
    attr_reader :connections, :api_key

    def initialize(urls, opts={})
      @connections = []
      @connections = urls.map { |u| URI.parse(u) }.map { |u| TCPSocket.new(u.host, u.port) }
      @api_key = opts[:api_key]
    end

    def close
      connections.each { |c| c.close }
    end

    def metric_name(name)
      api_key ? "#{api_key}.#{name}" : name  
    end

    def publish(name, value, time=Time.now.to_i)
      begin
        connections.sample.puts("#{metric_name(name)} #{value} #{time}")  
      rescue Errno::EPIPE => e
        raise e
      end
    end
  end
end
