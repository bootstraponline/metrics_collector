require 'sqlite3'
require 'forwardable'
require 'ostruct'

module MetricCollector

  class Db
    extend Forwardable
    def_delegator :@db, :execute

    attr_reader :db, :table_name

    def initialize opts={}
      database    = opts.fetch :database, ':memory:'
      sqlite_opts = { readonly: opts.fetch(:readonly, false) }
      @db         = SQLite3::Database.new database, sqlite_opts
      @table_name = 'http_complete_metric'

      unless sqlite_opts[:readonly]
        assert_sqlite_version
        make_table
      end
    end

    def assert_sqlite_version
      sqlite_version = db.execute('SELECT SQLITE_VERSION()').first.first
      sqlite_version = sqlite_version.split('.').map { |v| v.to_i } # parse string
      if (sqlite_version <=> [3, 7, 11]) == -1
        raise "Must be at least v3.7.11. Current version: v#{sqlite_version.join('.')}"
      end
    end

    def make_table
      db.execute <<-SQL
  create table if not exists #{table_name} (
    id           integer primary key autoincrement,
    local_time   int not null on conflict abort,
    local_value  int not null on conflict abort,
    remote_time  int not null on conflict abort,
    remote_value int not null on conflict abort
  );
      SQL
    end

    def insert opts={}
      local_time = opts[:local_time]
      raise 'local_time is required' unless local_time
      local_value = opts[:local_value]
      raise 'local_value is required' unless local_value
      remote_time = opts[:remote_time]
      raise 'remote_time is required' unless remote_time
      remote_value = opts[:remote_value]
      raise 'remote_value is required' unless remote_value

      db.execute "insert into #{table_name}  (local_time, local_value, remote_time, remote_value)
                values ( ?, ?, ?, ? )", [local_time, local_value, remote_time, remote_value]
    end

    # return last x ordered oldest to newest
    def select_last_as_array limit=10
      results = db.execute("select * from #{table_name} order by id desc limit #{limit}")
      values  = OpenStruct.new(id:           [],
                               local_time:   [],
                               local_value:  [],
                               remote_time:  [],
                               remote_value: [])

      results.reverse.each do |result|
        values.id << result[0]
        values.local_time << result[1]
        values.local_value << result[2]
        values.remote_time << result[3]
        values.remote_value << result[4]
      end

      values
    end

    # return last x ordered oldest to newest
    def select_last limit=10
      results = db.execute("select * from #{table_name} order by id desc limit #{limit}")
      objects = []

      results.reverse.each do |result|
        objects << OpenStruct.new(id:           result[0],
                                  local_time:   result[1],
                                  local_value:  result[2],
                                  remote_time:  result[3],
                                  remote_value: result[4])
      end

      objects
    end

    # Populate with data for testing
    # using metric 'httpTrafficCompleted'
    def populate opts
      # metric 'httpTrafficCompleted'
      local_time   = opts[:local_time]
      local_value  = opts[:local_value]
      remote_time  = opts[:remote_time]
      remote_value = opts[:remote_value]

      raise 'Must supply all args' unless local_time && local_value && remote_time && remote_value

      remote_time.length.times do |i|
        insert local_time:   local_time[i],
               local_value:  local_value[i],
               remote_time:  remote_time[i],
               remote_value: remote_value[i]
      end

      self
    end

    def self.fake_data
      local_time   = %w[1404416999 1404413426 1404409833 1404406244 1404402656
   1404399071 1404395480 1404391888 1404388298 1404384708]
      local_value  = %w[1 2 3 4 5 6 7 8 9 10]
      remote_time  = local_time
      remote_value = %w[11 12 13 14 15 16 17 18 19 20]
      OpenStruct.new(local_time:   local_time.map(&:to_i),
                     local_value:  local_value.map(&:to_i),
                     remote_time:  remote_time.map(&:to_i),
                     remote_value: remote_value.map(&:to_i))
    end
  end # class Db
end # module MetricCollector