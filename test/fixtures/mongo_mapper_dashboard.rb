require 'mongo_mapper'

class MongoMapperDashboard
  include MongoMapper::Document
  include Tenacity

  key :active_record_car_id, String

  t_has_one :active_record_climate_control_unit
end
