require 'spec_helper'

describe Backstop::Publisher do
  it "should initialize with an array of urls" do
    urls = ['tcp://10.0.0.1:5000', 'tcp://10.0.0.1:5001']
    TCPSocket.should_receive(:new).with('10.0.0.1', 5000)
    TCPSocket.should_receive(:new).with('10.0.0.1', 5001)
    b = Backstop::Publisher.new(urls)
    b.connections.count.should eq 2
  end
end
