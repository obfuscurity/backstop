require 'spec_helper'

describe Backstop::Publisher do
  it 'should initialize with an array of urls' do
    urls = ['tcp://10.0.0.1:5000', 'tcp://10.0.0.1:5001']
    TCPSocket.should_receive(:new).with('10.0.0.1', 5000)
    TCPSocket.should_receive(:new).with('10.0.0.1', 5001)
    b = Backstop::Publisher.new(urls)
    b.connections.count.should eq 2
  end

  it 'should publish data' do
    urls = ['tcp://10.0.0.1:5000']
    socket_double = double('TCPSocket')
    TCPSocket.should_receive(:new).with('10.0.0.1', 5000) { socket_double }
    b = Backstop::Publisher.new(urls)
    
    socket_double.should_receive(:puts).with("foo 1 1") 
    b.publish('foo', 1, 1)   
  end

  it 'should include a timestamp if you do not provide one' do
    urls = ['tcp://10.0.0.1:5000']
    socket_double = double('TCPSocket')
    TCPSocket.should_receive(:new).with('10.0.0.1', 5000) { socket_double }
    b = Backstop::Publisher.new(urls)

    Time.should_receive(:now) { 12345 }
    socket_double.should_receive(:puts).with("foo 1 12345")
    b.publish('foo', 1) 
  end
end
