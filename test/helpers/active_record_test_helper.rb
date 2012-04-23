require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:')

ActiveRecord::Schema.define :version => 0 do
  create_table :active_record_cars, :force => true do |t|
    t.string :prop
  end

  create_table :active_record_engines, :force => true do |t|
    t.string :prop
    t.integer :car_id
  end

  create_table :active_record_climate_control_units, :force => true do |t|
    t.string :mongo_mapper_dashboard_id
  end

  create_table :active_record_nuts, :force => true do |t|
    t.string :mongo_mapper_wheel_id
  end

  create_table :active_record_objects, :force => true do |t|
    t.string :prop
  end

  create_table :active_record_object_with_string_ids, :force => true, :id => false do |t|
    t.string :id, :limit => 36, :primary => true
  end
  
  create_table :active_record_users, :force => true do |t|
    t.integer :active_record_organization_id
  end
  
  create_table :active_record_organizations, :force => true do |t|
  end

  create_table :active_record_has_one_targets, :force => true do |t|
    t.integer :active_record_object_id
    t.string :couch_rest_object_id
    t.integer :data_mapper_object_id
    t.string :mongo_mapper_object_id
    t.string :mongoid_object_id
    t.string :ripple_object_id
    t.integer :sequel_object_id
    t.string :toystore_object_id

    t.string :active_record_has_one_target_testable_id
    t.string :active_record_has_one_target_testable_type
    t.string :couch_rest_has_one_target_testable_id
    t.string :couch_rest_has_one_target_testable_type
    t.string :data_mapper_has_one_target_testable_id
    t.string :data_mapper_has_one_target_testable_type
    t.string :mongo_mapper_has_one_target_testable_id
    t.string :mongo_mapper_has_one_target_testable_type
    t.string :mongoid_has_one_target_testable_id
    t.string :mongoid_has_one_target_testable_type
    t.string :ripple_has_one_target_testable_id
    t.string :ripple_has_one_target_testable_type
    t.string :sequel_has_one_target_testable_id
    t.string :sequel_has_one_target_testable_type
    t.string :toystore_has_one_target_testable_id
    t.string :toystore_has_one_target_testable_type
  end

  create_table :active_record_has_many_targets, :force => true do |t|
    t.integer :active_record_object_id
    t.string :couch_rest_object_id
    t.integer :data_mapper_object_id
    t.string :mongo_mapper_object_id
    t.string :mongoid_object_id
    t.string :ripple_object_id
    t.integer :sequel_object_id
    t.string :toystore_object_id

    t.string :active_record_has_many_target_testable_id
    t.string :active_record_has_many_target_testable_type
    t.string :couch_rest_has_many_target_testable_id
    t.string :couch_rest_has_many_target_testable_type
    t.string :data_mapper_has_many_target_testable_id
    t.string :data_mapper_has_many_target_testable_type
    t.string :mongo_mapper_has_many_target_testable_id
    t.string :mongo_mapper_has_many_target_testable_type
    t.string :mongoid_has_many_target_testable_id
    t.string :mongoid_has_many_target_testable_type
    t.string :ripple_has_many_target_testable_id
    t.string :ripple_has_many_target_testable_type
    t.string :sequel_has_many_target_testable_id
    t.string :sequel_has_many_target_testable_type
    t.string :toystore_has_many_target_testable_id
    t.string :toystore_has_many_target_testable_type
  end

end
