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
      puts "starting publish, connections is:"
      p connections
      c = connections.sample
      begin
        c.puts("#{metric_name(name)} #{value} #{time}")  
      rescue
        puts "exception"
        puts "attempting reconnect to remote socket"
        remote_port, remote_addr = c.peeraddr.slice(1,2)
        puts "remote port is #{remote_port}"
        puts "remote addr is #{remote_addr}"
        puts "closing connection"
        c.close
        puts "connections looks like:"
        p connections
        puts "opening a new connection"
        @connections.push(TCPSocket.new(remote_port, remote_addr))
        puts "now connections looks like:"
        p connections
        self.publish(name, value, time)
      end
    end
  end
end
