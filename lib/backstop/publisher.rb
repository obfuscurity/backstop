module Backstop
  class Publisher
    attr_reader :connections, :api_key

    def initialize(urls, opts={})
      @connections = []
      @connections = urls.map { |u| URI.parse(u) }.map { |u| TCPSocket.new(u.host, u.port) }
      @api_key = opts[:api_key]
    end

    def metric_name(name)
      api_key ? "#{api_key}.#{name}" : name  
    end

    def publish(name, value, time=Time.now.to_i)
      p connections
      c = connections.sample
      begin
        c.puts("#{metric_name(name)} #{value} #{time}")  
      rescue Errno::EPIPE => e
        puts "#{e.message}, attempting reconnect to remote socket"
        remote_port, remote_addr = c.peeraddr.slice(1,2)
        c.close
        @connections.push(TCPSocket.new(remote_port, remote_addr))
        self.publish(name, value, time)
      end
    end
  end
end
