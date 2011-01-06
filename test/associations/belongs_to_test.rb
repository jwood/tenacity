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

    should "be able to specify the class name of the associated class" do
      dashboard = MongoMapperDashboard.create
      ash_tray = MongoMapperAshTray.create(:dashboard => dashboard)
      assert_equal dashboard, ash_tray.dashboard
    end

    should "be able to specify the foreign key to use for the associated class" do
      car = ActiveRecordCar.create
      windshield = CouchRestWindshield.create(:active_record_car => car)
      assert_equal car.id.to_s, windshield.car_id
      assert !windshield.respond_to?(:active_record_car_id)

      engine = ActiveRecordEngine.create(:active_record_car => car)
      assert_equal car.id, engine.car_id
      assert !engine.respond_to?(:active_record_car_id)
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
      @nut = ActiveRecordNut.create
    end

    should "be able to fetch the id of the associated object" do
      @nut.mongo_mapper_wheel_id = @wheel.id
      @nut.save
      assert_equal @wheel.id.to_s, ActiveRecordNut.find(@nut.id).mongo_mapper_wheel_id
    end

    should "be able to load the associated object" do
      @nut.mongo_mapper_wheel = @wheel
      @nut.save
      assert_equal @wheel.id.to_s, ActiveRecordNut.find(@nut.id).mongo_mapper_wheel_id
      assert_equal @wheel, ActiveRecordNut.find(@nut.id).mongo_mapper_wheel
    end

    should "be be able to load the associated object if all we have is the id" do
      @nut.mongo_mapper_wheel_id = @wheel.id
      @nut.save
      assert_equal @wheel, ActiveRecordNut.find(@nut.id).mongo_mapper_wheel
    end

    should "return nil if no association is set" do
      assert_nil ActiveRecordNut.find(@nut.id).mongo_mapper_wheel
    end
  end

  context "A CouchRest class with belongs_to association to a MongoMapper class" do
    setup do
      setup_all_fixtures
      @dashboard = MongoMapperDashboard.create
      @radio = CouchRestRadio.create({})
    end

    should "be able to fetch the id of the associated object" do
      @radio.mongo_mapper_dashboard_id = @dashboard.id
      @radio.save
      assert_equal @dashboard.id.to_s, CouchRestRadio.find(@radio.id).mongo_mapper_dashboard_id
    end

    should "be able to load the associated object" do
      @radio.mongo_mapper_dashboard = @dashboard
      @radio.save
      assert_equal @dashboard.id.to_s, CouchRestRadio.find(@radio.id).mongo_mapper_dashboard_id
      assert_equal @dashboard, CouchRestRadio.find(@radio.id).mongo_mapper_dashboard
    end

    should "be be able to load the associated object if all we have is the id" do
      @radio.mongo_mapper_dashboard_id = @dashboard.id
      @radio.save
      assert_equal @dashboard, CouchRestRadio.find(@radio.id).mongo_mapper_dashboard
    end

    should "return nil if no association is set" do
      assert_nil CouchRestRadio.find(@radio.id).mongo_mapper_dashboard
    end
  end

end
