require 'mongo_mapper'

class MongoMapperCoil
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :mongoid_alternator
end
