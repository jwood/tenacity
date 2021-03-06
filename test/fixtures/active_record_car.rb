class ActiveRecordCar < ActiveRecord::Base
  include Tenacity

  t_has_many :mongo_mapper_wheels, :dependent => :destroy, :readonly => true, :limit => 5
  t_has_many :mongo_mapper_windows, :limit => 5, :offset => 3
  t_has_one :mongo_mapper_dashboard, :dependent => :delete, :readonly => true

  t_has_one :couch_rest_windshield, :foreign_key => :car_id
  t_has_one :active_record_engine, :foreign_key => 'car_id', :dependent => :nullify
  t_has_many :couch_rest_doors, :foreign_key => 'automobile_id', :dependent => :delete_all
end
