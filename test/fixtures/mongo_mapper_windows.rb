class MongoMapperWindow
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :active_record_car
end
