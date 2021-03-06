require 'rubygems'
require 'sinatra'
require 'liquid'
require 'json'
require 'uri'
=begin
Every hour
  - cloudbees sends server request to app.rb
    - contains local_time / local_value
    - app.rb acquires remote_time / remote_value
    - value is stored in the database
=end

# Force timezone
ENV['TZ'] = 'US/Eastern'

require_relative 'lib/capture_local'
require_relative 'lib/config'
require_relative 'lib/db'

include MetricCollector

# todo: read db from file
# todo: fix class variable access from toplevel
# todo: fix global var
def db
  $db ||= Db.new database: 'results.db'
end

# fake data is for testing only.
# db.populate Db.fake_data

# -- sinatra methods

def result_to_liquid
  # note: at least two data points must exist for the graph to display
  result = db.select_last_as_array

  # parse timestamps. 1404384708 => 6 AM
  labels = result.local_time.map { |time| Time.at(time).strftime('%l:%M %p').strip }.to_s

  # must convert to string for liquid
  local  = result.local_value.to_s
  remote = result.remote_value.to_s

  opts = MetricCollector::Config.load

  liquid :line, :locals => { labels: labels, red: local, blue: remote }.merge(opts)
end

get '/' do
  result_to_liquid
end

post '/' do
  # forbidden
  halt 403 unless params[:secret] == MetricCollector::Config.load['secret']

  # must validate all remote untrusted values
  remote_time  = params[:remote_time].to_i
  remote_value = params[:remote_value].to_i
  url          = URI(params[:url]).to_s
  runs         = params[:runs].to_i

  # bad request
  halt 404 unless remote_time && remote_value && url && runs

  # valid request
  remote = { remote_time: remote_time, remote_value: remote_value }

  local_time  = Time.now.to_i
  local_value = CaptureLocal.phantomas_median url: url, runs: runs
  local       = { local_time: local_time, local_value: local_value }

  complete = remote.merge(local)

  puts "Inserting: #{complete}"

=begin
phantomas records 0 on error.

sqlite> delete from http_complete_metric where remote_value == 0;
sqlite> delete from http_complete_metric where local_value == 0;
=end
  # only store update if the times are > 0.
  if (local_time > 0 && remote_time > 0)
    db.insert complete
  end

  # return obj to client to acknowledge success
  complete.to_json
end
