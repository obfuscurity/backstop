module Backstop
  class Publisher
    attr_reader :connections

    def initialize(urls)
      @connections = []
      @connections = urls.map { |u| URI.parse(u) }.map { |u| TCPSocket.new(u.host, u.port) }
    end
  end
end
