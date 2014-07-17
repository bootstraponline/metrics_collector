require 'toml'
module MetricCollector
  module Config
    def self.load
      return @data if @data
      secretToml = File.expand_path('../../secret.toml', __FILE__)
      puts "Loading: #{secretToml}"
      raise 'Missing toml' unless File.exist?(secretToml)
      @data = TOML.load_file(secretToml)
    end
  end
end