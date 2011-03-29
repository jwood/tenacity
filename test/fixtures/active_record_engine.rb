class ActiveRecordEngine < ActiveRecord::Base
  include Tenacity

  t_belongs_to :active_record_car, :foreign_key => 'car_id'
  t_has_many :mongo_mapper_circuit_boards, :as => :diagnosable
end
