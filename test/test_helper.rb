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
require File.join(File.dirname(__FILE__), 'helpers', 'couch_rest_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'mongo_mapper_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'mongoid_test_helper')

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tenacity'

Dir[File.join(File.dirname(__FILE__), 'fixtures', '*.rb')].each { |file| require file }

def setup_fixtures
  Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '*.rb')).each do |filename|
    begin
      filename =~ /.*\/(.*)\.rb/
      clazz = Kernel.const_get($1.camelcase)
      clazz.delete_all if clazz.respond_to?(:delete_all)
    rescue NameError
    end
  end

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

def setup_fixtures_for(source, target)
  if source == :couch_rest || target == :couch_rest
    setup_all_fixtures
  else
    setup_fixtures
  end
end

def orm_extensions
  extensions = [:active_record, :couch_rest, :mongo_mapper]
  require_mongoid { extensions << :mongoid }
  extensions
end

def for_each_orm_extension_combination
  orm_extensions.each do |source|
    orm_extensions.each do |target|
      yield source, target
    end
  end
end

def class_for_extension(extension, type=nil)
  if type.nil?
    class_name = extension.to_s.camelcase + "Object"
  elsif type == :belongs_to || type == :has_one
    class_name = extension.to_s.camelcase + "HasOneTarget"
  end
  Kernel.const_get(class_name)
end

def foreign_key_for(extension, type)
  if type == :belongs_to
    "#{extension}_object"
  elsif type == :has_one
    "#{extension}_has_one_target"
  end
end

def foreign_key_id_for(extension, type)
  foreign_key_for(extension, type) + "_id"
end

def assert_set_equal(expecteds, actuals, message = nil)
  assert_equal expecteds && Set.new(expecteds), actuals && Set.new(actuals), message
end

