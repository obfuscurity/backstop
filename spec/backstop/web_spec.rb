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
    let(:good_collectd_data) { File.open(File.dirname(__FILE__) + '/good_collectd_data.json').read }
    let(:bad_collectd_data) { File.open(File.dirname(__FILE__) + '/bad_collectd_data.json').read }
    let(:generic_collectd_data) { File.open(File.dirname(__FILE__) + '/generic_collectd_data.json').read }

    it 'should require JSON' do
      post '/collectd', 'foo'
      last_response.should_not be_ok
      last_response.status.should eq(400)
    end

    it 'should handle a collectd metric' do
      p = double('publisher')
      Backstop::Publisher.should_receive(:new) { p }
      p.should_receive(:publish).with('mitt.leeloo.octo.it.cpu.0.idle', 1901474177, 1280959128)      
      post '/collectd', good_collectd_data
      last_response.body.should eq('ok')
      last_response.status.should eq(200)
    end

    it 'should complain if missing fields' do
      post '/collectd', bad_collectd_data
      last_response.status.should eq(400)
      last_response.body.should eq('missing fields')
    end

    it 'should handle a generic collectd metric' do
      p = double('publisher')
      Backstop::Publisher.should_receive(:new) { p }
      p.should_receive(:publish).with('mitt.leeloo.octo.it.irq.IWI', 42, 1423949215.334)
      post '/collectd', generic_collectd_data
      last_response.body.should eq('ok')
      last_response.status.should eq(200)
    end
  end

  context 'POST /github' do
    let(:good_github_data) { File.open(File.dirname(__FILE__) + '/good_github_data.json').read }
    let(:bad_github_data) { File.open(File.dirname(__FILE__) + '/bad_github_data.json').read }

    it 'should require JSON' do
      post '/github', { :payload => 'foo' }
      last_response.should_not be_ok
      last_response.status.should eq(400) 
    end

    it 'should take a github push' do
      p = double('publisher')
      Backstop::Publisher.should_receive(:new) { p }
      p.should_receive(:publish).with('github.github.refs.heads.master.chris-ozmm-org.de8251ff97ee194a289832576287d6f8ad74e3d0', 1, '1203114994')
      p.should_receive(:publish).with('github.github.refs.heads.master.chris-ozmm-org.41a212ee83ca127e3c8cf465891ab7216a705f59', 1, '1203116237')
      post '/github', { :payload => good_github_data }
      last_response.should be_ok
    end

    it 'should complain if missing fields' do
      post '/github', { :payload => bad_github_data }
      last_response.should_not be_ok
    end
  end
end


