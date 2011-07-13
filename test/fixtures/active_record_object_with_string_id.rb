class ActiveRecordObjectWithStringId < ActiveRecord::Base
  include Tenacity

  t_has_one :mongo_mapper_object
end
