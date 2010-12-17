class ActiveRecordClimateControlUnit < ActiveRecord::Base
  include Tenacity

  t_belongs_to :mongo_mapper_dashboard
end
