class MongoMapperDashboard
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :active_record_car
  t_has_one :active_record_climate_control_unit
  t_has_one :couch_rest_radio

  t_has_many :vents, :class_name => 'MongoMapperVent', :foreign_keys_property => 'dashboard_vent_ids'
  t_has_one :ash_tray, :class_name => 'MongoMapperAshTray'
end
