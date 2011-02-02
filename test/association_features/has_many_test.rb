require 'test_helper'

class HasManyTest < Test::Unit::TestCase

  context "A class with a belongs_to association to another class" do
    setup do
      setup_all_fixtures
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

      context "the delete method" do
        should "not delete the object from the database if no dependent option is specified" do
          dashboard = MongoMapperDashboard.create
          vent_1 = MongoMapperVent.create
          vent_2 = MongoMapperVent.create
          vent_3 = MongoMapperVent.create
          dashboard.vents = [vent_1, vent_2, vent_3]
          dashboard.save
          assert_set_equal [vent_1, vent_2, vent_3], MongoMapperDashboard.find(dashboard.id).vents

          dashboard.vents.delete(vent_1)
          dashboard.save
          assert_set_equal [vent_2, vent_3], MongoMapperDashboard.find(dashboard.id).vents
          assert_not_nil MongoMapperVent.find(vent_1.id)
        end

        should "delete the associated object and issue callbacks if association is configured to :destroy dependents" do
          wheel_1 = MongoMapperWheel.create
          wheel_2 = MongoMapperWheel.create
          wheel_3 = MongoMapperWheel.create
          @new_car.mongo_mapper_wheels = [wheel_1, wheel_2, wheel_3]
          @new_car.save
          assert_set_equal [wheel_1, wheel_2, wheel_3], ActiveRecordCar.find(@new_car.id).mongo_mapper_wheels

          @new_car.mongo_mapper_wheels.delete(wheel_1)
          @new_car.save
          assert_set_equal [wheel_2, wheel_3], ActiveRecordCar.find(@new_car.id).mongo_mapper_wheels
          assert_nil MongoMapperWheel._t_find(wheel_1.id.to_s)
        end

        should "delete the associated object without issuing callbacks if association is configured to :delete_all dependents" do
          @new_car.couch_rest_doors.delete(@door_1)
          @new_car.save
          assert_set_equal [@door_2, @door_3], ActiveRecordCar.find(@new_car.id).couch_rest_doors
          assert_nil CouchRestDoor._t_find(@door_1.id.to_s)
        end
      end

      context "the clear method" do
        should "not delete the object from the database if no dependent option is specified" do
          dashboard = MongoMapperDashboard.create
          vent_1 = MongoMapperVent.create
          vent_2 = MongoMapperVent.create
          dashboard.vents = [vent_1, vent_2]
          dashboard.save
          assert_set_equal [vent_1, vent_2], MongoMapperDashboard.find(dashboard.id).vents

          dashboard.vents.clear
          dashboard.save
          assert_set_equal [], MongoMapperDashboard.find(dashboard.id).vents
          assert_not_nil MongoMapperVent.find(vent_1.id)
          assert_not_nil MongoMapperVent.find(vent_2.id)
        end

        should "delete the associated object and issue callbacks if association is configured to :destroy dependents" do
          wheel_1 = MongoMapperWheel.create
          wheel_2 = MongoMapperWheel.create
          @new_car.mongo_mapper_wheels = [wheel_1, wheel_2]
          @new_car.save
          assert_set_equal [wheel_1, wheel_2], ActiveRecordCar.find(@new_car.id).mongo_mapper_wheels

          @new_car.mongo_mapper_wheels.clear
          @new_car.save
          assert_set_equal [], ActiveRecordCar.find(@new_car.id).mongo_mapper_wheels
          assert_nil MongoMapperWheel._t_find(wheel_1.id.to_s)
          assert_nil MongoMapperWheel._t_find(wheel_2.id.to_s)
        end

        should "delete the associated object without issuing callbacks if association is configured to :delete_all dependents" do
          @new_car.couch_rest_doors.clear
          @new_car.save
          assert_set_equal [], ActiveRecordCar.find(@new_car.id).couch_rest_doors
          assert_nil CouchRestDoor._t_find(@door_1.id.to_s)
          assert_nil CouchRestDoor._t_find(@door_2.id.to_s)
          assert_nil CouchRestDoor._t_find(@door_3.id.to_s)
        end
      end
    end
  end

end
