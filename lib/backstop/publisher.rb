module Backstop
  class Publisher
    attr_reader :connections

    def initialize(urls)
      @connections = []
      @connections = urls.map { |u| URI.parse(u) }.map { |u| TCPSocket.new(u.host, u.port) }
    end

    def publish(name, value, time=Time.now.to_i)
      connections.sample.puts("#{name} #{value} #{time}")  
    end
  end
end
