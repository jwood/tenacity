class ActiveRecordCar < ActiveRecord::Base
  include Tenacity

  t_has_many :mongo_mapper_wheels
  t_has_one :mongo_mapper_dashboard
end
