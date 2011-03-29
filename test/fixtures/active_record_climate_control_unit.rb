class ActiveRecordClimateControlUnit < ActiveRecord::Base
  include Tenacity

  t_belongs_to :mongo_mapper_dashboard
  t_has_one :mongo_mapper_circuit_board, :as => :diagnosable
end
