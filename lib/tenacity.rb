require File.join('active_support', 'inflector')

require File.join(File.dirname(__FILE__), 'tenacity', 'associate_proxy')
require File.join(File.dirname(__FILE__), 'tenacity', 'associates_proxy')
require File.join(File.dirname(__FILE__), 'tenacity', 'association')
require File.join(File.dirname(__FILE__), 'tenacity', 'class_methods')
require File.join(File.dirname(__FILE__), 'tenacity', 'errors')
require File.join(File.dirname(__FILE__), 'tenacity', 'instance_methods')
require File.join(File.dirname(__FILE__), 'tenacity', 'associations', 'belongs_to')
require File.join(File.dirname(__FILE__), 'tenacity', 'associations', 'has_many')
require File.join(File.dirname(__FILE__), 'tenacity', 'associations', 'has_one')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'activerecord')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'couchrest')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'datamapper')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'mongo_mapper')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'mongoid')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'sequel')

module Tenacity #:nodoc:
  include InstanceMethods

  include Associations::BelongsTo
  include Associations::HasMany
  include Associations::HasOne

  def self.included(model)
    OrmExt::ActiveRecord.setup(model)
    OrmExt::CouchRest.setup(model)
    OrmExt::DataMapper.setup(model)
    OrmExt::MongoMapper.setup(model)
    OrmExt::Mongoid.setup(model)
    OrmExt::Sequel.setup(model)

    raise "Tenacity does not support the database client used by #{model}" unless model.respond_to?(:_t_find)
    model.extend(ClassMethods)
  end
end

