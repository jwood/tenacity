require 'test_helper'

class BelongsToTest < Test::Unit::TestCase

  context "A class with a belongs_to association to another class" do
    setup do
      setup_fixtures
      @car = ActiveRecordCar.create
      @wheel = MongoMapperWheel.create(:active_record_car => @car)
    end

    should "memoize the association" do
      assert_equal @car, @wheel.active_record_car

      other_car = ActiveRecordCar.create
      assert_equal @car, MongoMapperWheel.find(@wheel.id).active_record_car
      MongoMapperWheel.update(@wheel.id, :active_record_car => other_car)
      assert_equal other_car, MongoMapperWheel.find(@wheel.id).active_record_car

      assert_equal @car, @wheel.active_record_car
      assert_equal other_car, @wheel.active_record_car(true)
    end
  end

  context "A MongoMapper class with belongs_to association to an ActiveRecord class" do
    setup do
      setup_fixtures
      @car = ActiveRecordCar.create
      @wheel = MongoMapperWheel.create
    end

    should "be able to fetch the id of the associated object" do
      @wheel.active_record_car_id = @car.id
      @wheel.save
      assert_equal @car.id, MongoMapperWheel.find(@wheel.id).active_record_car_id.to_i
    end

    should "be able to load the associated object" do
      @wheel.active_record_car = @car
      @wheel.save
      assert_equal @car.id, MongoMapperWheel.find(@wheel.id).active_record_car_id.to_i
      assert_equal @car, MongoMapperWheel.find(@wheel.id).active_record_car
    end

    should "be able to load the associated object if all we have is the id" do
      @wheel.active_record_car_id = @car.id
      @wheel.save
      assert_equal @car, MongoMapperWheel.find(@wheel.id).active_record_car
    end

    should "return nil if no association is set" do
      assert_nil MongoMapperWheel.find(@wheel.id).active_record_car
    end
  end

  context "An ActiveRecord class with belongs_to association to a MongoMapper class" do
    setup do
      setup_fixtures
      @wheel = MongoMapperWheel.create
      @transaction = ActiveRecordNut.create
    end

    should "be able to fetch the id of the associated object" do
      @transaction.mongo_mapper_wheel_id = @wheel.id
      @transaction.save
      assert_equal @wheel.id.to_s, ActiveRecordNut.find(@transaction.id).mongo_mapper_wheel_id
    end

    should "be able to load the associated object" do
      @transaction.mongo_mapper_wheel = @wheel
      @transaction.save
      assert_equal @wheel.id.to_s, ActiveRecordNut.find(@transaction.id).mongo_mapper_wheel_id
      assert_equal @wheel, ActiveRecordNut.find(@transaction.id).mongo_mapper_wheel
    end

    should "be be able to load the associated object if all we have is the id" do
      @transaction.mongo_mapper_wheel_id = @wheel.id
      @transaction.save
      assert_equal @wheel, ActiveRecordNut.find(@transaction.id).mongo_mapper_wheel
    end

    should "return nil if no association is set" do
      assert_nil ActiveRecordNut.find(@transaction.id).mongo_mapper_wheel
    end
 end

end
