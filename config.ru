# config.ru from https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#_sinatra
require 'rubygems'
require 'sinatra'

set :environment, ENV['RACK_ENV'].to_sym
disable :run, :reload

require_relative 'app.rb'

run Sinatra::Application