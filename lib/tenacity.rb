require File.join('active_support', 'inflector')

require File.join(File.dirname(__FILE__), 'tenacity', 'classmethods')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'activerecord')
require File.join(File.dirname(__FILE__), 'tenacity', 'orm_ext', 'mongo_mapper')
require File.join(File.dirname(__FILE__), 'tenacity', 'relationships', 'belongs_to')
require File.join(File.dirname(__FILE__), 'tenacity', 'relationships', 'has_many')
require File.join(File.dirname(__FILE__), 'tenacity', 'relationships', 'has_one')

module Tenacity
  include ClassMethods

  include HasMany
  include BelongsTo

  def self.included(model)
    raise "Tenacity does not support the ORM used by #{model}" unless model.respond_to?(:_t_find)
    model.extend(ClassMethods)
  end
end

