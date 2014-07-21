require 'posix-spawn'
require 'uri'

module MetricCollector
  class CaptureLocal
=begin

Use median value of x number of runs for httpTrafficCompleted metric. not using average because some results
may be 0 if there are problems.

$ phantomas http://www.google.com/ --runs 2
.-----------------------------------------------------------------------------------------------------------.
| Report from 2 run(s) for <http://www.google.com/> using phantomas v1.3.0                                  |
|-----------------------------------------------------------------------------------------------------------|
|             Metric             |     min      |     max      |   average    |    median    |    stddev    |
|--------------------------------|--------------|--------------|--------------|--------------|--------------|
| httpTrafficCompleted           |          683 |          800 |        741.5 |        741.5 |         58.5 |
=end

    # phantomas_median url: 'http://www.google.com/', runs: 2
    #
    # returns nil on failure
    # returns median as float value on success
    def self.phantomas_median opts={}
      raise 'url must be provided' unless opts[:url]
      raise 'runs must be provided' unless opts[:runs]
      # must validate that url is a url and runs is an int
      url  = URI(opts[:url]).to_s
      runs = opts[:runs].to_i

      raise 'runs must be >= 2' unless runs.to_i >= 2

      child = POSIX::Spawn::Child.new('phantomas', url, '--runs', runs.to_s)
      match = child.out.match(/httpTrafficCompleted.*$/)
      return nil unless match # match will be nil on failure to match.

      match                                     = match.to_s.split('|')
      # puts match # for debugging

      metric, min, max, average, median, stddev = match
      median.to_f
    end
  end # class CaptureLocal
end # module MetricCollector