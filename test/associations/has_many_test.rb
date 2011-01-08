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
  end

  context "An ActiveRecord class with a has_many association to a MongoMapper class" do
    setup do
      setup_fixtures
      @car = ActiveRecordCar.create
      @wheel_1 = MongoMapperWheel.create
      @wheel_2 = MongoMapperWheel.create
      @wheel_3 = MongoMapperWheel.create
    end

    should "be able to set the associated objects by their ids" do
      @car.mongo_mapper_wheel_ids = [@wheel_1.id, @wheel_2.id, @wheel_3.id]
      @car.save
      assert_set_equal [@wheel_1, @wheel_2, @wheel_3], ActiveRecordCar.find(@car.id).mongo_mapper_wheels
      assert_set_equal [@wheel_1.id.to_s, @wheel_2.id.to_s, @wheel_3.id.to_s], ActiveRecordCar.find(@car.id).mongo_mapper_wheel_ids
    end

    context "that works with associated objects" do
      setup do
        @car.mongo_mapper_wheels = [@wheel_1, @wheel_2, @wheel_3]
        @car.save
      end

      should "be able to set the associated objects" do
        assert_set_equal [@wheel_1, @wheel_2, @wheel_3], ActiveRecordCar.find(@car.id).mongo_mapper_wheels
      end

      should "be able to add an associated object using the << operator" do
        wheel_4 = MongoMapperWheel.create
        @car.mongo_mapper_wheels << wheel_4
        @car.save
        assert_set_equal [@wheel_1, @wheel_2, @wheel_3, wheel_4], ActiveRecordCar.find(@car.id).mongo_mapper_wheels
      end

      should "be able to remove an associated object using the delete method" do
        @car.mongo_mapper_wheels.delete(@wheel_3)
        @car.save
        assert_set_equal [@wheel_1, @wheel_2], ActiveRecordCar.find(@car.id).mongo_mapper_wheels
      end

      should "be able to clear all associated objects using the clear method" do
        @car.mongo_mapper_wheels.clear
        @car.save
        assert_equal [], ActiveRecordCar.find(@car.id).mongo_mapper_wheels
      end

      should "return an empty array if the association is not set" do
        car = ActiveRecordCar.create
        assert_set_equal [], ActiveRecordCar.find(car.id).mongo_mapper_wheels
      end
    end
  end

  context "A MongoMapper class with a has_many association to an ActiveRecord class" do
    setup do
      setup_fixtures
      @wheel = MongoMapperWheel.create
      @nut_1 = ActiveRecordNut.create
      @nut_2 = ActiveRecordNut.create
      @nut_3 = ActiveRecordNut.create
    end

    should "be able to set the associated objects by their ids" do
      @wheel.active_record_nut_ids = [@nut_1.id, @nut_2.id, @nut_3.id]
      @wheel.save
      assert_set_equal [@nut_1, @nut_2, @nut_3], MongoMapperWheel.find(@wheel.id).active_record_nuts
      assert_set_equal [@nut_1.id.to_s, @nut_2.id.to_s, @nut_3.id.to_s], MongoMapperWheel.find(@wheel.id).active_record_nut_ids
    end

    context "that works with associated objects" do
      setup do
        @wheel.active_record_nuts = [@nut_1, @nut_2, @nut_3]
        @wheel.save
      end

      should "be able to set the associated objects" do
        assert_set_equal [@nut_1, @nut_2, @nut_3], MongoMapperWheel.find(@wheel.id).active_record_nuts
      end

      should "be able to add an associated object using the << operator" do
        nut_4 = ActiveRecordNut.create
        @wheel.active_record_nuts << nut_4
        @wheel.save
        assert_set_equal [@nut_1, @nut_2, @nut_3, nut_4], MongoMapperWheel.find(@wheel.id).active_record_nuts
      end

      should "be able to remove an associated object using the delete method" do
        @wheel.active_record_nuts.delete(@nut_3)
        @wheel.save
        assert_set_equal [@nut_1, @nut_2], MongoMapperWheel.find(@wheel.id).active_record_nuts
      end

      should "be able to clear all associated objects using the clear method" do
        @wheel.active_record_nuts.clear
        @wheel.save
        assert_set_equal [], MongoMapperWheel.find(@wheel.id).active_record_nuts
      end

      should "return an empty array if the association is not set" do
        wheel = MongoMapperWheel.create
        assert_set_equal [], MongoMapperWheel.find(wheel.id).active_record_nuts
      end
    end
  end

  context "A CouchRest class with a has_many association to a MongoMapper class" do
    setup do
      setup_all_fixtures
      @radio = CouchRestRadio.create({})
      @button_1 = MongoMapperButton.create
      @button_2 = MongoMapperButton.create
      @button_3 = MongoMapperButton.create
    end

    should "be able to set the associated objects by their ids" do
      @radio.mongo_mapper_button_ids = [@button_1.id, @button_2.id, @button_3.id]
      @radio.save
      assert_set_equal [@button_1, @button_2, @button_3], CouchRestRadio.get(@radio.id).mongo_mapper_buttons
      assert_set_equal [@button_1.id.to_s, @button_2.id.to_s, @button_3.id.to_s], CouchRestRadio.get(@radio.id).mongo_mapper_button_ids
    end

    context "that works with associated objects" do
      setup do
        @radio.mongo_mapper_buttons = [@button_1, @button_2, @button_3]
        @radio.save
      end

      should "be able to set the associated objects" do
        assert_set_equal [@button_1, @button_2, @button_3], CouchRestRadio.get(@radio.id).mongo_mapper_buttons
      end

      should "be able to add an associated object using the << operator" do
        button_4 = MongoMapperButton.create
        @radio.mongo_mapper_buttons << button_4
        @radio.save
        assert_set_equal [@button_1, @button_2, @button_3, button_4], CouchRestRadio.get(@radio.id).mongo_mapper_buttons
      end

      should "be able to remove an associated object using the delete method" do
        @radio.mongo_mapper_buttons.delete(@button_3)
        @radio.save
        assert_set_equal [@button_1, @button_2], CouchRestRadio.get(@radio.id).mongo_mapper_buttons
      end

      should "be able to clear all associated objects using the clear method" do
        @radio.mongo_mapper_buttons.clear
        @radio.save
        assert_equal [], CouchRestRadio.get(@radio.id).mongo_mapper_buttons
      end

      should "return an empty array if the association is not set" do
        radio = CouchRestRadio.create({})
        assert_set_equal [], CouchRestRadio.get(radio.id).mongo_mapper_buttons
      end
    end
  end

end
