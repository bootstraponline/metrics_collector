require 'rubygems'
require 'sinatra'
require 'liquid'

=begin
- [x] display line graph
- [x] use liquid to display graph with data
- [x] setup sqlite -- decided not to use an ORM
- [ ] capture local metrics
- [ ] capture remote metrics
- [ ] deploy with passenger / digitalocean
=end

require_relative 'db'

db = Db.new
db.populate

get '/' do
  labels = db.last_10_labels.to_s
  local  = db.last_10_local.to_s
  remote = db.last_10_remote.to_s

  liquid :line, :locals => { labels: labels, red: local, blue: remote }
end