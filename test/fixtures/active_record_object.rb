class ActiveRecordObject < ActiveRecord::Base
  include Tenacity

  t_has_one :active_record_has_one_target
  t_has_one :couch_rest_has_one_target
  t_has_one :data_mapper_has_one_target
  t_has_one :mongo_mapper_has_one_target
  require_mongoid { t_has_one :mongoid_has_one_target }
  t_has_one :sequel_has_one_target

  t_has_one :active_record_has_one_target, :as => :active_record_has_one_target_testable
  t_has_one :couch_rest_has_one_target, :as => :couch_rest_has_one_target_testable
  t_has_one :data_mapper_has_one_target, :as => :data_mapper_has_one_target_testable
  t_has_one :mongo_mapper_has_one_target, :as => :mongo_mapper_has_one_target_testable
  require_mongoid { t_has_one :mongoid_has_one_target, :as => :mongoid_has_one_target_testable }
  t_has_one :sequel_has_one_target, :as => :sequel_has_one_target_testable

  t_has_many :active_record_has_many_targets
  t_has_many :couch_rest_has_many_targets
  t_has_many :data_mapper_has_many_targets
  t_has_many :mongo_mapper_has_many_targets
  require_mongoid { t_has_many :mongoid_has_many_targets }
  t_has_many :sequel_has_many_targets

  t_has_one :mongo_mapper_autosave_true_has_one_target, :autosave => true
  t_has_one :mongo_mapper_autosave_false_has_one_target, :autosave => false
  t_has_many :mongo_mapper_autosave_true_has_many_targets, :autosave => true
  t_has_many :mongo_mapper_autosave_false_has_many_targets, :autosave => false
end
