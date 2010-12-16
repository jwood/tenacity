require 'mongo_mapper'

class MongoMapperLedger
  include MongoMapper::Document
  include Tenacity
end
