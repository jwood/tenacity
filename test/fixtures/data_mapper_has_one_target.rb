class DataMapperHasOneTarget
  include DataMapper::Resource
  include Tenacity

  property :id, Serial
  property :active_record_object_id, String
  property :couch_rest_object_id, String
  property :data_mapper_object_id, String
  property :mongo_mapper_object_id, String
  property :mongoid_object_id, String
  property :sequel_object_id, String

  t_belongs_to :active_record_object
  t_belongs_to :couch_rest_object
  t_belongs_to :data_mapper_object
  t_belongs_to :mongo_mapper_object
  require_mongoid { t_belongs_to :mongoid_object }
  t_belongs_to :sequel_object
end
