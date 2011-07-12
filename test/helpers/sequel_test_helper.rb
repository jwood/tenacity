require 'sequel'

DB = Sequel.sqlite
Sequel::Model.raise_on_save_failure = true

DB.create_table :sequel_objects do
  primary_key :id
  String :prop
end

DB.create_table :sequel_object_with_string_ids do
  String :id, :primary_key => true
end

DB.create_table :sequel_has_one_targets do
  primary_key :id

  Integer :active_record_object_id
  String :couch_rest_object_id
  Integer :data_mapper_object_id
  String :mongo_mapper_object_id
  String :mongoid_object_id
  String :ripple_object_id
  Integer :sequel_object_id
  String :toystore_object_id

  String :active_record_has_one_target_testable_id
  String :active_record_has_one_target_testable_type
  String :couch_rest_has_one_target_testable_id
  String :couch_rest_has_one_target_testable_type
  String :data_mapper_has_one_target_testable_id
  String :data_mapper_has_one_target_testable_type
  String :mongo_mapper_has_one_target_testable_id
  String :mongo_mapper_has_one_target_testable_type
  String :mongoid_has_one_target_testable_id
  String :mongoid_has_one_target_testable_type
  String :ripple_has_one_target_testable_id
  String :ripple_has_one_target_testable_type
  String :sequel_has_one_target_testable_id
  String :sequel_has_one_target_testable_type
  String :toystore_has_one_target_testable_id
  String :toystore_has_one_target_testable_type
end

DB.create_table :sequel_has_many_targets do
  primary_key :id

  Integer :active_record_object_id
  String :couch_rest_object_id
  Integer :data_mapper_object_id
  String :mongo_mapper_object_id
  String :mongoid_object_id
  String :ripple_object_id
  Integer :sequel_object_id
  String :toystore_object_id

  String :active_record_has_many_target_testable_id
  String :active_record_has_many_target_testable_type
  String :couch_rest_has_many_target_testable_id
  String :couch_rest_has_many_target_testable_type
  String :data_mapper_has_many_target_testable_id
  String :data_mapper_has_many_target_testable_type
  String :mongo_mapper_has_many_target_testable_id
  String :mongo_mapper_has_many_target_testable_type
  String :mongoid_has_many_target_testable_id
  String :mongoid_has_many_target_testable_type
  String :ripple_has_many_target_testable_id
  String :ripple_has_many_target_testable_type
  String :sequel_has_many_target_testable_id
  String :sequel_has_many_target_testable_type
  String :toystore_has_many_target_testable_id
  String :toystore_has_many_target_testable_type
end

