require 'rubygems'
require 'sinatra'
require 'liquid'
require 'json'

=begin
- [x] display line graph
- [x] use liquid to display graph with data
- [x] setup sqlite -- decided not to use an ORM
- [ ] capture local metrics
- [ ] capture remote metrics
- [ ] deploy with passenger / digitalocean


gem install rest-client
  -- post to sinatra

RestClient.post url: 'http://localhost:4567/'

Every hour
  - cloudbees sends server request to app.rb
    - contains local_time / local_value
    - app.rb aquires remote_time / remote_value
    - value is stored in the database
=end

require_relative 'lib/db'
require_relative 'lib/capture_local'

include MetricCollector

# todo: read db from file
# todo: fix class variable access from toplevel
def db
  @@db ||= Db.new
end

# -- sinatra methods

def result_to_liquid
  # note: at least two data points must exist for the graph to display
  result = db.select_last_as_array

  # parse timestamps. 1404384708 => 6 AM
  labels = result.local_time.map { |time| Time.at(time).strftime('%l:%M %p').strip }.to_s

  # must convert to string for liquid
  local  = result.local_value.to_s
  remote = result.remote_value.to_s

  liquid :line, :locals => { labels: labels, red: local, blue: remote }
end

get '/' do
  result_to_liquid
end

def secret
  @@secret ||= File.read('secret.txt').strip
end

post '/' do
  # forbidden
  halt 403 unless params[:secret] == secret

  remote_time  = params[:remote_time]
  remote_value = params[:remote_value]
  url          = params[:url]
  runs         = params[:runs]

  # bad request
  halt 404 unless remote_time && remote_value && url && runs

  # valid request
  remote = { remote_time: remote_time, remote_value: remote_value }

  local_time  = Time.now.to_i
  local_value = CaptureLocal.phantomas_median url: url, runs: runs
  local       = { local_time: local_time, local_value: local_value }

  complete = remote.merge(local)

  db.insert complete

  # return obj to client to acknowledge success
  complete.to_json
end