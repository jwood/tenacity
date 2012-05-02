class ActiveRecordSeet < ActiveRecord::Base
  include Tenacity
  
  t_belongs_to :active_record_car, :foreign_key => 'car_id', :polymorphic => false
end
