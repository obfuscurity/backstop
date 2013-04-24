module Backstop
  class Publisher
    attr_reader :connections, :api_key

    def initialize(urls, opts={})
      @connections = []
      @connections = urls.map { |u| URI.parse(u) }.map { |u| connect_to(u.host, u.port, 1) }
      @api_key = opts[:api_key]
    end

    def connect_to(host, port, timeout)
      addr = Socket.getaddrinfo(host, nil)
      sock = Socket.new(Socket.const_get(addr[0][0]), Socket::SOCK_STREAM, 0)

      if timeout
        secs = Integer(timeout)
        usecs = Integer((timeout - secs) * 1_000_000)
        optval = [secs, usecs].pack("l_2")
        sock.setsockopt Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, optval
        sock.setsockopt Socket::SOL_SOCKET, Socket::SO_SNDTIMEO, optval
      end
      sock.connect(Socket.pack_sockaddr_in(port, addr[0][3]))
      sock
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
