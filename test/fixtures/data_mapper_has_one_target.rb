class DataMapperHasOneTarget
  include DataMapper::Resource
  include Tenacity

  property :id, Serial
  property :active_record_object_id, Integer
  property :couch_rest_object_id, String
  property :data_mapper_object_id, Integer
  property :mongo_mapper_object_id, String
  property :mongoid_object_id, String
  property :ripple_object_id, String
  property :sequel_object_id, Integer
  property :toystore_object_id, String

  property :active_record_has_one_target_testable_id, String
  property :active_record_has_one_target_testable_type, String
  property :couch_rest_has_one_target_testable_id, String
  property :couch_rest_has_one_target_testable_type, String
  property :data_mapper_has_one_target_testable_id, String
  property :data_mapper_has_one_target_testable_type, String
  property :mongo_mapper_has_one_target_testable_id, String
  property :mongo_mapper_has_one_target_testable_type, String
  property :mongoid_has_one_target_testable_id, String
  property :mongoid_has_one_target_testable_type, String
  property :ripple_has_one_target_testable_id, String
  property :ripple_has_one_target_testable_type, String
  property :sequel_has_one_target_testable_id, String
  property :sequel_has_one_target_testable_type, String
  property :toystore_has_one_target_testable_id, String
  property :toystore_has_one_target_testable_type, String

  t_belongs_to :active_record_object
  t_belongs_to :couch_rest_object
  t_belongs_to :data_mapper_object
  t_belongs_to :mongo_mapper_object
  require_mongoid { t_belongs_to :mongoid_object }
  require_ripple { t_belongs_to :ripple_object }
  t_belongs_to :sequel_object
  require_toystore { t_belongs_to :toystore_object }

  t_belongs_to :active_record_has_one_target_testable, :polymorphic => true
  t_belongs_to :couch_rest_has_one_target_testable, :polymorphic => true
  t_belongs_to :data_mapper_has_one_target_testable, :polymorphic => true
  t_belongs_to :mongo_mapper_has_one_target_testable, :polymorphic => true
  require_mongoid { t_belongs_to :mongoid_has_one_target_testable, :polymorphic => true }
  require_ripple { t_belongs_to :ripple_has_one_target_testable, :polymorphic => true }
  t_belongs_to :sequel_has_one_target_testable, :polymorphic => true
  require_toystore { t_belongs_to :toystore_has_one_target_testable, :polymorphic => true }
end
