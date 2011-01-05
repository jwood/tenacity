require 'mongo_mapper'

class MongoMapperAshTray
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :dashboard, :class_name => 'MongoMapperDashboard'
end
