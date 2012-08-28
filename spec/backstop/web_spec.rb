require 'spec_helper'

require 'backstop/web'
require 'rack/test'

describe Backstop::Application do
  include Rack::Test::Methods

  def app
    Backstop::Application
  end

  before(:each) do
    app.class_variable_set :@@publisher, nil
  end

  context 'GET /health' do
    it 'should handle GET /health' do
      get '/health'
      last_response.should be_ok
    end
  end

  context 'POST /publish/:name' do
    it 'should require JSON' do
      post '/publish/foo', 'foo'
      last_response.should_not be_ok  
      last_response.status.should eq(400) 
    end

    it 'should handle a single metric' do
      p = double('publisher')
      Backstop::Publisher.should_receive(:new) { p }
      p.should_receive(:publish).with('test.bar', 12345, 1)
      post '/publish/test', { :metric => 'bar', :value => 12345, :measure_time => 1 }.to_json
      last_response.should be_ok
    end

    it 'should handle an array of metrics' do
      p = double('publisher')
      Backstop::Publisher.should_receive(:new) { p }
      p.should_receive(:publish).with('test.bar', 12345, 1)
      p.should_receive(:publish).with('test.bar', 12344, 2)
      post '/publish/test', [{ :metric => 'bar', :value => 12345, :measure_time => 1 }, { :metric => 'bar', :value => 12344, :measure_time => 2} ].to_json
      last_response.should be_ok
    end
  end

  context 'POST /collectd' do
    let(:collectd_data) { File.open(File.dirname(__FILE__) + '/good_collectd_data.json').read }
    let(:bad_collectd_data) { File.open(File.dirname(__FILE__) + '/bad_collectd_data.json').read }

    it 'should require JSON' do
      post '/collectd', 'foo'
      last_response.should_not be_ok
      last_response.status.should eq(400)
    end

    it 'should handle a collectd metric' do
      p = double('publisher')
      Backstop::Publisher.should_receive(:new) { p }
      p.should_receive(:publish).with('mitt.leeloo.octo.it.cpu.0.idle', 1901474177, 1280959128)      
      post '/collectd', collectd_data
      last_response.body.should eq('ok')
      last_response.status.should eq(200)
    end

    it 'should complain if missing fields' do
      post '/collectd', bad_collectd_data
      last_response.status.should eq(400)
      last_response.body.should eq('missing fields')
    end
  end
end


