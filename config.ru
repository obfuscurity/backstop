$:.unshift File.dirname(__FILE__) + '/lib'
require 'backstop/web'

run Backstop::Application
