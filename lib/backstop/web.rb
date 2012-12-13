require 'sinatra'
require 'socket'
require 'json'

require 'backstop/publisher'
require 'backstop/config'
require 'backstop/collectd/parser'

module Backstop
  class Application < Sinatra::Base
    configure do
      enable :logging
      require 'newrelic_rpm'
      @@publisher = nil
    end

    helpers do
      def publisher
        @@publisher ||= Backstop::Publisher.new(Config.carbon_urls)
      end
    end

    get '/health' do
      {'health' => 'ok'}.to_json
    end

    post '/collectd' do
      begin
        data = JSON.parse(request.body.read)
      rescue JSON::ParserError
        halt 400, 'JSON is required'
      end
      data.each do |item|
        results = CollectdData.new(item).parse
        results.each do |r|
          r['source'] = 'collectd'
          halt 400, 'missing fields' unless (r[:cloud] && r[:slot] && r[:id] && r[:metric] && r[:value] && r[:measure_time])
          r[:cloud].gsub!(/\./, '-')
          publisher.publish("mitt.#{r[:cloud]}.#{r[:slot]}.#{r[:id]}.#{r[:metric]}", r[:value], r[:measure_time])
        end
      end
      'ok'
    end
    
    post '/github' do
      begin
        data = JSON.parse(params[:payload])
      rescue JSON::ParserError
        halt 400, 'JSON is required'
      end
      halt 400, 'missing fields' unless (data['repository'] && data['commits'])
      data['source'] = 'github'
      data['ref'].gsub!(/\//, '.')
      data['commits'].each do |commit|
        repo = data['repository']['name']
        author = commit['author']['email'].gsub(/[\.@]/, '-')
        measure_time = DateTime.parse(commit['timestamp']).strftime('%s')
        publisher.publish("#{data['source']}.#{repo}.#{data['ref']}.#{author}.#{commit['id']}", 1, measure_time)
      end
      'ok'
    end

    post '/publish/:name' do
      begin
        data = JSON.parse(request.body.read)
      rescue JSON::ParserError
        halt 400, 'JSON is required'
      end
      if Config.prefixes.include?(params[:name])
        if data.kind_of? Array
          data.each do |item|
            item['source'] = params[:name]
            halt 400, 'missing fields' unless (item['metric'] && item['value'] && item['measure_time'])
            publisher.publish("#{item['source']}.#{item['metric']}", item['value'], item['measure_time'])
          end 
        else 
          data['source'] = params[:name]
          halt 400, 'missing fields' unless (data['metric'] && data['value'] && data['measure_time'])
          publisher.publish("#{data['source']}.#{data['metric']}", data['value'], data['measure_time'])
        end
        'ok'
      else
        halt 404, 'unknown prefix'
      end
    end
  end
end
