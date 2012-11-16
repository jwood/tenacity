class ActiveRecordObjectWithStringId < ActiveRecord::Base
  include Tenacity

  self.primary_key = 'id'

  t_has_one :mongo_mapper_object
end
