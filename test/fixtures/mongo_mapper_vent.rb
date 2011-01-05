require 'mongo_mapper'

class MongoMapperVent
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :dashboard, :class_name => 'MongoMapperDashboard'
end
