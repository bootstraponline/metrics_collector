require 'rubygems'
require 'rest-client'

require_relative '../lib/capture_local'

# sample: ruby post_to_server.rb http://localhost:4567/ http://www.google.com 2

def secret
  File.read(File.expand_path('../../secret.txt', __FILE__)).strip
end

raise 'Must supply server, webpage url and run count' unless ARGV && ARGV.length == 3

server = ARGV[0]
url    = ARGV[1]
runs   = ARGV[2]

# run count of 1 means phantomas uses a different report and the values won't be parsed.
raise 'Runs must be >= 2' unless runs.to_i >= 2

time   = Time.now.to_i
median = MetricCollector::CaptureLocal.phantomas_median url: url, runs: runs

opts = { secret:       secret,
         url:          url,
         runs:         runs,
         remote_time:  time,
         remote_value: median }

RestClient.post server, opts