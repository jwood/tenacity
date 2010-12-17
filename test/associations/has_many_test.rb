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
        person_4 = MongoMapperWheel.create
        @car.mongo_mapper_wheels << person_4
        @car.save
        assert_set_equal [@wheel_1, @wheel_2, @wheel_3, person_4], ActiveRecordCar.find(@car.id).mongo_mapper_wheels
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
      assert_set_equal [@nut_1.id, @nut_2.id, @nut_3.id], MongoMapperWheel.find(@wheel.id).active_record_nut_ids
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
    end
  end

end
