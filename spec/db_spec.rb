require_relative 'helper'

# rspec spec/db_spec.rb
module MetricCollector
  describe Db do

    attr_reader :db, :local_time, :local_value, :remote_time, :remote_value

    before do
      # default is in memory
      @db = Db.new.populate(Db.fake_data)

      expected      = Db.fake_data
      @local_time   = expected.local_time
      @local_value  = expected.local_value
      @remote_time  = expected.remote_time
      @remote_value = expected.remote_value
    end

    it :select_last do
      results = db.select_last 999

      expect(results.length).to eq(10)

      results.each_with_index do |result, index|
        expect(local_time[index]).to eq(result.local_time)
        expect(local_value[index]).to eq(result.local_value)
        expect(remote_time[index]).to eq(result.remote_time)
        expect(remote_value[index]).to eq(result.remote_value)
      end
    end

    it :select_last_as_array do
      result = db.select_last_as_array 999

      expect(local_time).to eq(result.local_time)
      expect(local_value).to eq(result.local_value)
      expect(remote_time).to eq(result.remote_time)
      expect(remote_value).to eq(result.remote_value)
    end

    it 'supports readonly mode' do
      readonly_database = Db.new readonly: true
      expect { readonly_database.make_table }.to raise_error(SQLite3::ReadOnlyException)
    end
  end
end