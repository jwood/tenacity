require 'mongo_mapper'

class MongoMapperWheel
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :active_record_car
  t_has_many :active_record_nuts
end
