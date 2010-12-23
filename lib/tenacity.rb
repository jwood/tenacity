require File.join('active_support', 'inflector')

require File.join(File.dirname(__FILE__), 'tenacity', 'class_methods')
require File.join(File.dirname(__FILE__), 'tenacity', 'instance_methods')
require File.join(File.dirname(__FILE__), 'tenacity', 'associations', 'belongs_to')
require File.join(File.dirname(__FILE__), 'tenacity', 'associations', 'has_many')
require File.join(File.dirname(__FILE__), 'tenacity', 'associations', 'has_one')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'activerecord')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'couchrest', 'tenacity_class_methods')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'couchrest', 'tenacity_instance_methods')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'couchrest', 'couchrest_extended_document')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'couchrest', 'couchrest_model')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'mongo_mapper')

module Tenacity #:nodoc:
  include InstanceMethods

  include BelongsTo
  include HasMany
  include HasOne

  def self.included(model)
    raise "Tenacity does not support the ORM used by #{model}" unless model.respond_to?(:_t_find)
    model.extend(ClassMethods)
  end
end

