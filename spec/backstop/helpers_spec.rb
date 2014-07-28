require 'spec_helper'

require 'backstop/helpers'
require 'rack/test'

describe Backstop::Helpers do
  include Backstop::Helpers
  include Rack::Test::Methods

  let(:helpers) { TestHelper.new }
  let(:request) { double(:request, :env => 'env') }

  describe '#authorized?' do

    before :each do
      Rack::Auth::Basic::Request.stub(:new).and_return(double("Auth", :provided? => true, :basic? => true, :credentials => ['user','password']))
    end

    context 'with only one authorized account' do
      it 'matches the account' do
        ENV.stub(:[]).with("BACKSTOP_AUTH").and_return("user:password")
        expect(authorized?).to be true
      end
    end

    context 'with multiple authorized accounts' do
      it 'matches the account' do
        ENV.stub(:[]).with("BACKSTOP_AUTH").and_return("anotheruser:anotherpassword,user:password")
        expect(authorized?).to be true
      end
    end
  end
end
