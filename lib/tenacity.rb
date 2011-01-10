require File.join('active_support', 'inflector')

require File.join(File.dirname(__FILE__), 'tenacity', 'associates_proxy')
require File.join(File.dirname(__FILE__), 'tenacity', 'association')
require File.join(File.dirname(__FILE__), 'tenacity', 'class_methods')
require File.join(File.dirname(__FILE__), 'tenacity', 'instance_methods')
require File.join(File.dirname(__FILE__), 'tenacity', 'associations', 'belongs_to')
require File.join(File.dirname(__FILE__), 'tenacity', 'associations', 'has_many')
require File.join(File.dirname(__FILE__), 'tenacity', 'associations', 'has_one')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'activerecord')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'couchrest')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'mongo_mapper')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'mongoid')

module Tenacity #:nodoc:
  include InstanceMethods

  include BelongsTo
  include HasMany
  include HasOne

  def self.included(model)
    include_active_record(model)
    include_couchrest(model)
    include_mongo_mapper(model)
    include_mongoid(model)

    raise "Tenacity does not support the database client used by #{model}" unless model.respond_to?(:_t_find)
    model.extend(ClassMethods)
  end

  private

  def self.include_active_record(model)
    require 'active_record'
    if model.superclass == ::ActiveRecord::Base
      model.send :include, ActiveRecord::InstanceMethods
      model.extend ActiveRecord::ClassMethods
    end
  rescue LoadError
    # ActiveRecord not available
  end

  def self.include_couchrest(model)
    begin
      require 'couchrest_model'
      if model.superclass == ::CouchRest::Model::Base
        model.send :include, CouchRest::InstanceMethods
        model.extend CouchRest::ClassMethods
      end
    rescue LoadError
      # CouchRest::Model not available
    end

    begin
      require 'couchrest_extended_document'
      if model.superclass == ::CouchRest::ExtendedDocument
        model.send :include, CouchRest::InstanceMethods
        model.extend CouchRest::ClassMethods
      end
    rescue LoadError
      # CouchRest::ExtendedDocument not available
    end
  end

  def self.include_mongo_mapper(model)
    require 'mongo_mapper'
    if model.included_modules.include?(::MongoMapper::Document)
      model.send :include, MongoMapper::InstanceMethods
      model.extend MongoMapper::ClassMethods
    end
  rescue LoadError
    # MongoMapper not available
  end

  def self.include_mongoid(model)
    require 'mongoid'
    if model.included_modules.include?(::Mongoid::Document)
      model.send :include, Mongoid::InstanceMethods
      model.extend Mongoid::ClassMethods
    end
  rescue LoadError
    # Mongoid not available
  end

end

