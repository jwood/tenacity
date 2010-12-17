class ActiveRecordAccount < ActiveRecord::Base
  include Tenacity

  t_has_many :mongo_mapper_people
  t_has_one :mongo_mapper_ledger
end
