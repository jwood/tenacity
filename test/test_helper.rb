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
require 'mocha'

require File.join(File.dirname(__FILE__), 'helpers', 'active_record_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'couch_rest_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'data_mapper_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'mongo_mapper_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'mongoid_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'sequel_test_helper')

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tenacity'

Dir[File.join(File.dirname(__FILE__), 'fixtures', '*.rb')].each { |file| require file }

DataMapper.auto_migrate!

def setup_fixtures
  Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '*.rb')).each do |filename|
    begin
      filename =~ /.*\/(.*)\.rb/
      clazz = Kernel.const_get($1.camelcase)
      if clazz.respond_to?(:delete_all)
        clazz.delete_all
      elsif clazz.respond_to?(:db)
        clazz.db["delete from #{clazz.table_name}"].delete
      elsif clazz.respond_to?(:destroy)
        clazz.destroy
      elsif filename =~ /\/couch_rest/
        # CouchDB fixtures are destroyed with the database
      else
        puts "WARN: Don't know how to clear fixtures for #{clazz}"
      end
    rescue NameError
    end
  end

  join_tables = %w{
                    active_record_cars_mongo_mapper_wheels
                    active_record_cars_couch_rest_doors
                    nuts_and_wheels
                    active_record_has_many_targets_active_record_objects
                    active_record_objects_mongo_mapper_has_many_targets
                    active_record_objects_couch_rest_has_many_targets
                    active_record_objects_mongoid_has_many_targets
                  }
  join_tables.each { |join_table| ActiveRecordCar.connection.execute("delete from #{join_table}") }
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
  extensions = [:active_record, :couch_rest, :data_mapper, :mongo_mapper, :sequel]
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
  elsif type == :has_many
    class_name = extension.to_s.camelcase + "HasManyTarget"
  end
  Kernel.const_get(class_name)
end

def foreign_key_for(extension, type)
  if type == :belongs_to
    "#{extension}_object"
  elsif type == :has_one
    "#{extension}_has_one_target"
  elsif type == :has_many
    "#{extension}_has_many_targets"
  end
end

def foreign_key_id_for(extension, type)
  if type == :belongs_to
    "#{extension}_object_id"
  elsif type == :has_one
    "#{extension}_has_one_target_id"
  elsif type == :has_many
    "#{extension}_has_many_target_ids"
  end
end

def assert_set_equal(expecteds, actuals, message = nil)
  assert_equal expecteds && Set.new(expecteds), actuals && Set.new(actuals), message
end

