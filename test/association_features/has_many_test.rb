require 'test_helper'

class HasManyTest < Test::Unit::TestCase

  context "A class with a belongs_to association to another class" do
    setup do
      setup_fixtures
      @car = ActiveRecordCar.create
      @wheels = [MongoMapperWheel.create, MongoMapperWheel.create, MongoMapperWheel.create]

      @car.mongo_mapper_wheels = @wheels
      @car.save
    end

    should "memoize the association" do
      assert_equal @wheels, @car.mongo_mapper_wheels

      other_wheels = [MongoMapperWheel.create, MongoMapperWheel.create, MongoMapperWheel.create]
      assert_equal @wheels, ActiveRecordCar.find(@car.id).mongo_mapper_wheels
      ActiveRecordCar.find(@car.id).update_attribute(:mongo_mapper_wheels, other_wheels)
      assert_equal other_wheels, ActiveRecordCar.find(@car.id).mongo_mapper_wheels

      assert_equal @wheels, @car.mongo_mapper_wheels
      assert_equal other_wheels, @car.mongo_mapper_wheels(true)
    end

    should "be able to specify the class name of the associated class" do
      vent_1 = MongoMapperVent.create
      vent_2 = MongoMapperVent.create
      vent_3 = MongoMapperVent.create
      dashboard = MongoMapperDashboard.create
      dashboard.vents = [vent_1, vent_2, vent_3]
      dashboard.save
      assert_set_equal [vent_1, vent_2, vent_3], MongoMapperDashboard.find(dashboard.id).vents
    end

    should "be able to specify the foreign key to use for the class" do
      car = ActiveRecordCar.create
      door_1 = CouchRestDoor.create({})
      door_2 = CouchRestDoor.create({})
      door_3 = CouchRestDoor.create({})
      car.couch_rest_doors = [door_1, door_2, door_3]
      car.save

      assert_set_equal [door_1, door_2, door_3], ActiveRecordCar.find(car.id).couch_rest_doors
      assert_set_equal [door_1.id.to_s, door_2.id.to_s, door_3.id.to_s], ActiveRecordCar.find(car.id).couch_rest_door_ids
    end

    should "save the associate object when it is added as an associate if the parent object is saved" do
      car = ActiveRecordCar.create
      door_1 = CouchRestDoor.new({})
      assert_nil door_1.id

      old_count = CouchRestDoor.count
      car.couch_rest_doors << door_1
      assert_equal old_count + 1, CouchRestDoor.count
    end

    should "not save the associate object when it is added as an associate if the parent object is not saved" do
      car = ActiveRecordCar.new
      door_1 = CouchRestDoor.new({})
      assert_nil door_1.id

      old_count = CouchRestDoor.count
      car.couch_rest_doors << door_1
      assert_equal old_count, CouchRestDoor.count
    end

    should "save all unsaved associates when the parent object is saved" do
      car = ActiveRecordCar.new
      door_1 = CouchRestDoor.new({})
      assert_nil door_1.id

      old_count = CouchRestDoor.count
      car.couch_rest_doors << door_1
      assert_equal old_count, CouchRestDoor.count
      car.save
      assert_equal old_count + 1, CouchRestDoor.count
      assert_set_equal [door_1], ActiveRecordCar.find(car.id).couch_rest_doors
    end

    context "with a set of associates that need to be deleted" do
      setup do
        @new_car = ActiveRecordCar.create
        @door_1 = CouchRestDoor.create({})
        @door_2 = CouchRestDoor.create({})
        @door_3 = CouchRestDoor.create({})
        @new_car.couch_rest_doors = [@door_1, @door_2, @door_3]
        @new_car.save
      end

      should "be able to delete all associates" do
        assert_set_equal [@door_1, @door_2, @door_3], ActiveRecordCar.find(@new_car.id).couch_rest_doors
        old_count = CouchRestDoor.count
        @new_car.couch_rest_doors.delete_all
        assert_equal old_count - 3, CouchRestDoor.count
        assert_set_equal [], ActiveRecordCar.find(@new_car.id).couch_rest_doors
      end

      should "be able to destroy all associates" do
        assert_set_equal [@door_1, @door_2, @door_3], ActiveRecordCar.find(@new_car.id).couch_rest_doors
        old_count = CouchRestDoor.count
        @new_car.couch_rest_doors.destroy_all
        assert_equal old_count - 3, CouchRestDoor.count
        assert_set_equal [], ActiveRecordCar.find(@new_car.id).couch_rest_doors
      end
    end
  end

end
