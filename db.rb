require 'sqlite3'
require 'forwardable'

class Db
  extend Forwardable
  def_delegator :@db, :execute

  attr_reader :db, :local, :remote

  def initialize
    @db     = SQLite3::Database.new ':memory:'
    @local  = 'local_metrics' # local table name
    @remote = 'remote_metrics' # remote table name
    assert_sqlite_version
    make_table
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
  create table if not exists local_metrics (
    id integer primary key autoincrement,
    time int,
    value int
  );
    SQL

    db.execute <<-SQL
  create table if not exists remote_metrics (
    id integer primary key autoincrement,
    time int,
    value int
  );
    SQL
  end

  def _insert table, time, value
    db.execute "insert into #{table} (time, value) values ( ?, ? )", [time, value]
  end

  def insert_local time, value
    _insert local, time, value
  end

  def insert_remote time, value
    _insert remote, time, value
  end

  # return last ten ordered oldest to newest
  def _last_10 table, keys='time, value'
    db.execute("select #{keys} from #{table} order by id desc limit 10").flatten
  end

  def last_10_local
    _last_10 local, 'value'
  end

  def last_10_remote
    _last_10 remote, 'value'
  end

  def last_10_labels
    _last_10(local, 'time').map { |time| Time.at(time).strftime('%l %p').strip }
  end

  # Populate with 10 fake datapoints for testing
  def populate
    time   = %w[1404416999 1404413426 1404409833 1404406244 1404402656
   1404399071 1404395480 1404391888 1404388298 1404384708]
    remote = %w[25 22 40 67 15 3 22 40 67 15]
    local  = %w[23 65 13 4 11 23 65 13 4 15]

    time.length.times do |index|
      insert_remote time[index], remote[index]
      insert_local  time[index], local[index]
    end
  end
end