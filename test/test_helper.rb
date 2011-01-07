require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'shoulda'

require File.join(File.dirname(__FILE__), 'helpers', 'active_record_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'mongo_mapper_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'couch_rest_test_helper')

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tenacity'

Dir[File.join(File.dirname(__FILE__), 'fixtures', '*.rb')].each { |file| require file }

def setup_fixtures
  ActiveRecordCar.delete_all
  ActiveRecordClimateControlUnit.delete_all
  ActiveRecordEngine.delete_all
  ActiveRecordClimateControlUnit.delete_all
  ActiveRecordNut.delete_all
  MongoMapperDashboard.delete_all
  MongoMapperWheel.delete_all

  ActiveRecordCar.connection.execute("delete from active_record_cars_mongo_mapper_wheels")
  ActiveRecordCar.connection.execute("delete from active_record_cars_couch_rest_doors")
  ActiveRecordCar.connection.execute("delete from nuts_and_wheels")
end

def setup_couchdb_fixtures
  COUCH_DB.recreate! rescue nil
end

def setup_all_fixtures
  setup_fixtures
  setup_couchdb_fixtures
end

def assert_set_equal(expecteds, actuals, message = nil)
  assert_equal expecteds && Set.new(expecteds), actuals && Set.new(actuals), message
end

