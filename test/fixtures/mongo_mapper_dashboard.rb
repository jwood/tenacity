require 'mongo_mapper'

class MongoMapperDashboard
  include MongoMapper::Document
  include Tenacity

  t_has_one :active_record_climate_control_unit
end
