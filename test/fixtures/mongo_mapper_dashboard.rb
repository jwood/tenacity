require 'mongo_mapper'

class MongoMapperDashboard
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :active_record_car
  t_has_one :active_record_climate_control_unit
  t_has_one :couch_rest_radio
end
