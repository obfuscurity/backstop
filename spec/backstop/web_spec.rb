require 'spec_helper'

require 'backstop/web'
require 'rack/test'

set :environment, :test
 
describe Backstop::Application do
  include Rack::Test::Methods

  def app
    Backstop::Application
  end

  it 'responds to /health' do
    get '/health'
    last_response.should be_ok
  end
end
