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

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'tenacity'

require File.join(File.dirname(__FILE__), 'helpers', 'active_record_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'couch_rest_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'data_mapper_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'mongo_mapper_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'mongoid_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'ripple_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'sequel_test_helper')
require File.join(File.dirname(__FILE__), 'helpers', 'toystore_test_helper')

Dir[File.join(File.dirname(__FILE__), 'fixtures', '*.rb')].each { |file| autoload(file[file.rindex('/') + 1..-4].camelcase, file) }

migrate_data_mapper_tables

def setup_fixtures
  Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', '*.rb')).each do |filename|
    begin
      filename =~ /.*\/(.*)\.rb/
      clazz = Kernel.const_get($1.camelcase)
      if clazz.respond_to?(:delete_all)
        clazz.delete_all
      elsif clazz.respond_to?(:db)
        clazz.db["delete from #{clazz.table_name}"].delete
      elsif clazz.respond_to?(:destroy!)
        clazz.destroy!
      elsif filename =~ /\/toystore/
        # No way to easily delete toystore instances per class, so delete them all.
        Mongo::Connection.new.db('tenacity_test')['toystore'].remove
      elsif filename =~ /\/couch_rest/
        # CouchDB fixtures are destroyed with the database
      elsif filename =~ /\/ripple/
        # Ripple fixtures are destroyed explicitly in setup_ripple_fixtures
      else
        puts "WARNING: Don't know how to clear fixtures for #{clazz}"
      end
    rescue NameError
    end
  end
end

def setup_couchdb_fixtures
  COUCH_DB.recreate! rescue nil
end

def setup_ripple_fixtures
  require_ripple do
    bucket_names = ripple_classes.map { |clazz| clazz.bucket.name }

    # XXX: This is --INCREDIBLY-- slow, but I cannot find a better/faster way of doing it
    Ripple.client.buckets.each do |bucket|
      if bucket_names.include?(bucket.name) || bucket.name =~ /^tenacity_test_/
        bucket.keys { |keys| keys.each { |k| bucket.delete(k) } }
      end
    end
  end
end

def setup_fixtures_for(source, target)
  setup_fixtures
  setup_couchdb_fixtures if source == :couch_rest || target == :couch_rest
  setup_ripple_fixtures if source == :ripple || target == :ripple
end

def orm_extensions
  if ENV['QUICK'] == 'true'
    extensions = [:active_record, :mongo_mapper]
  else
    extensions = [:active_record, :couch_rest, :data_mapper, :mongo_mapper, :sequel]
    require_mongoid { extensions << :mongoid }
    require_ripple { extensions << :ripple } if ENV['LONG'] == 'true'
    require_toystore { extensions << :toystore }
    extensions
  end
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
  elsif type == :t_belongs_to || type == :t_has_one
    class_name = extension.to_s.camelcase + "HasOneTarget"
  elsif type == :t_has_many
    class_name = extension.to_s.camelcase + "HasManyTarget"
  end
  Kernel.const_get(class_name)
end

def foreign_key_for(extension, type)
  if type == :t_belongs_to
    "#{extension}_object"
  elsif type == :t_has_one
    "#{extension}_has_one_target"
  elsif type == :t_has_many
    "#{extension}_has_many_targets"
  end
end

def foreign_key_id_for(extension, type)
  if type == :t_belongs_to
    "#{extension}_object_id"
  elsif type == :t_has_one
    "#{extension}_has_one_target_id"
  elsif type == :t_has_many
    "#{extension}_has_many_target_ids"
  end
end

def assert_set_equal(expecteds, actuals, message = nil)
  assert ((expecteds && Set.new(expecteds)) == (actuals && Set.new(actuals))) || (expecteds == actuals),
    "#{expecteds.inspect} expected but was #{actuals.inspect}"
end

def serialize_id(object)
  object.class._t_serialize(object.id)
end

def ripple_classes
  Dir.glob(File.join(File.dirname(__FILE__), 'fixtures', 'ripple_*.rb')).map do |filename|
    filename =~ /.*\/(.*)\.rb/
    Kernel.const_get($1.camelcase)
  end
end

