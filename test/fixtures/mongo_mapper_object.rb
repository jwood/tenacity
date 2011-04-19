class MongoMapperObject
  include MongoMapper::Document
  include Tenacity

  t_has_one :active_record_has_one_target
  t_has_one :couch_rest_has_one_target
  t_has_one :data_mapper_has_one_target
  t_has_one :mongo_mapper_has_one_target
  require_mongoid { t_has_one :mongoid_has_one_target }
  require_ripple { t_has_one :ripple_has_one_target }
  t_has_one :sequel_has_one_target

  t_has_many :active_record_has_many_targets
  t_has_many :couch_rest_has_many_targets
  t_has_many :data_mapper_has_many_targets
  t_has_many :mongo_mapper_has_many_targets
  require_mongoid { t_has_many :mongoid_has_many_targets }
  require_ripple { t_has_many :ripple_has_many_targets }
  t_has_many :sequel_has_many_targets

  t_has_one :active_record_has_one_target, :as => :active_record_has_one_target_testable
  t_has_one :couch_rest_has_one_target, :as => :couch_rest_has_one_target_testable
  t_has_one :data_mapper_has_one_target, :as => :data_mapper_has_one_target_testable
  t_has_one :mongo_mapper_has_one_target, :as => :mongo_mapper_has_one_target_testable
  require_mongoid { t_has_one :mongoid_has_one_target, :as => :mongoid_has_one_target_testable }
  require_ripple { t_has_one :ripple_has_one_target, :as => :ripple_has_one_target_testable }
  t_has_one :sequel_has_one_target, :as => :sequel_has_one_target_testable

  t_has_many :active_record_has_many_targets, :as => :active_record_has_many_target_testable
  t_has_many :couch_rest_has_many_targets, :as => :couch_rest_has_many_target_testable
  t_has_many :data_mapper_has_many_targets, :as => :data_mapper_has_many_target_testable
  t_has_many :mongo_mapper_has_many_targets, :as => :mongo_mapper_has_many_target_testable
  require_mongoid { t_has_many :mongoid_has_many_targets, :as => :mongoid_has_many_target_testable }
  require_ripple { t_has_many :ripple_has_many_targets, :as => :ripple_has_many_target_testable }
  t_has_many :sequel_has_many_targets, :as => :sequel_has_many_target_testable
end
