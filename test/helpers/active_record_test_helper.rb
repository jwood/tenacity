require 'active_record'

ActiveRecord::Base.establish_connection(
  :adapter => 'sqlite3',
  :database => ':memory:')

ActiveRecord::Schema.define :version => 0 do
  create_table :active_record_cars, :force => true do |t|
  end

  create_table :active_record_engines, :force => true do |t|
    t.integer :car_id
  end

  create_table :active_record_climate_control_units, :force => true do |t|
    t.string :mongo_mapper_dashboard_id
  end

  create_table :active_record_cars_mongo_mapper_wheels, :force => true do |t|
    t.integer :active_record_car_id
    t.string :mongo_mapper_wheel_id
  end

  create_table :active_record_cars_couch_rest_doors, :force => true do |t|
    t.integer :active_record_car_id
    t.string :couch_rest_door_id
  end

  create_table :active_record_nuts, :force => true do |t|
    t.string :mongo_mapper_wheel_id
  end

  create_table :nuts_and_wheels, :force => true do |t|
    t.integer :nut_id
    t.string :mongo_mapper_wheel_id
  end

  create_table :active_record_objects, :force => true do |t|
  end

  create_table :active_record_has_one_targets, :force => true do |t|
    t.string :active_record_object_id
    t.string :couch_rest_object_id
    t.string :data_mapper_object_id
    t.string :mongo_mapper_object_id
    t.string :mongoid_object_id
  end

  create_table :active_record_has_many_targets, :force => true do |t|
    t.integer :active_record_object_id
    t.string :couch_rest_object_id
    t.string :data_mapper_object_id
    t.string :mongo_mapper_object_id
    t.string :mongoid_object_id
  end

  create_table :active_record_has_many_targets_active_record_objects, :force => true do |t|
    t.integer :active_record_object_id
    t.string :active_record_has_many_target_id
  end

  create_table :active_record_objects_mongo_mapper_has_many_targets, :force => true do |t|
    t.integer :active_record_object_id
    t.string :mongo_mapper_has_many_target_id
  end

  create_table :active_record_objects_couch_rest_has_many_targets, :force => true do |t|
    t.integer :active_record_object_id
    t.string :couch_rest_has_many_target_id
  end

  create_table :active_record_objects_data_mapper_has_many_targets, :force => true do |t|
    t.integer :active_record_object_id
    t.string :data_mapper_has_many_target_id
  end

  create_table :active_record_objects_mongoid_has_many_targets, :force => true do |t|
    t.integer :active_record_object_id
    t.string :mongoid_has_many_target_id
  end
end
