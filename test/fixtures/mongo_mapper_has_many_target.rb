class MongoMapperHasManyTarget
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :active_record_object
  t_belongs_to :couch_rest_object
  t_belongs_to :data_mapper_object
  t_belongs_to :mongo_mapper_object
  require_mongoid { t_belongs_to :mongoid_object }
  t_belongs_to :sequel_object
end
