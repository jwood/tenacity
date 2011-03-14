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
      assert_equal car.id, windshield.car_id
      assert !windshield.respond_to?(:active_record_car_id)

      engine = ActiveRecordEngine.create(:active_record_car => car)
      assert_equal car.id, engine.car_id
      assert !engine.respond_to?(:active_record_car_id)
    end

    should "not be able to modify the associated object if the readonly option is set" do
      engine = ActiveRecordEngine.create
      air_filter = MongoMapperAirFilter.create(:active_record_engine => engine)
      engine = air_filter.active_record_engine
      engine.prop = "value"
      assert_raises(Tenacity::ReadOnlyError) { engine.save }
    end

    should "save the associated object if autosave is true" do
      source = MongoMapperAutosaveTrueHasOneTarget.create
      target = ActiveRecordObject.create(:prop => 'abc')
      source.active_record_object = target
      source.save
      assert_equal 'abc', source.active_record_object.prop

      source.active_record_object.prop = 'xyz'
      source.save
      source.reload && source.active_record_object(true)
      assert_equal 'xyz', source.active_record_object.prop
    end
  end

end
