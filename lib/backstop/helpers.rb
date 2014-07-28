require 'sinatra'

module Backstop::Helpers
  def protected!
    return unless ENV['BACKSTOP_AUTH']
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and ENV['BACKSTOP_AUTH'].split(',').collect{|auth| auth.split(':')}.include?(@auth.credentials)
  end
  def publisher
    @@publisher ||= Backstop::Publisher.new(Backstop::Config.carbon_urls, :api_key => Backstop::Config.api_key)
  end
  def send(metric, value, time)
    begin
      publisher.publish(metric, value, time)
    rescue
      publisher.close_all
      @@publisher = nil
    end
  end
end
