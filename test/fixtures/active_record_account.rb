class ActiveRecordAccount < ActiveRecord::Base
  include Tenacity

  t_has_many :mongo_mapper_people
end
