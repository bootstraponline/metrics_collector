# config.ru from https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#_sinatra
require 'rubygems'
require 'sinatra'

# :development, :test, or :production
# default is dev
set :environment, :production
disable :run, :reload

require_relative 'app.rb'

run Sinatra::Application