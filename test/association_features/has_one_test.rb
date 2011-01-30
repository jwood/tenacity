require 'test_helper'

class HasOneTest < Test::Unit::TestCase

  context "A class with a has_one association to another class" do
    setup do
      setup_all_fixtures
      @climate_control_unit = ActiveRecordClimateControlUnit.create
      @dashboard = MongoMapperDashboard.create(:active_record_climate_control_unit => @climate_control_unit)
    end

    should "memoize the association" do
      assert_equal @climate_control_unit, @dashboard.active_record_climate_control_unit

      other_climate_control_unit = ActiveRecordClimateControlUnit.create
      assert_equal @climate_control_unit, MongoMapperDashboard.find(@dashboard.id).active_record_climate_control_unit
      ActiveRecordClimateControlUnit.update(@climate_control_unit.id, :mongo_mapper_dashboard_id => nil)
      ActiveRecordClimateControlUnit.update(other_climate_control_unit.id, :mongo_mapper_dashboard_id => @dashboard.id)
      assert_equal other_climate_control_unit, MongoMapperDashboard.find(@dashboard.id).active_record_climate_control_unit

      assert_equal @climate_control_unit, @dashboard.active_record_climate_control_unit
      assert_equal other_climate_control_unit, @dashboard.active_record_climate_control_unit(true)
    end

    should "be able to specify the class name of the associated class" do
      ash_tray = MongoMapperAshTray.create
      dashboard = MongoMapperDashboard.create(:ash_tray => ash_tray)
      assert_equal ash_tray, dashboard.ash_tray
    end

    should "be able to specify the foreign key to use for the class" do
      car = ActiveRecordCar.create
      windshield = CouchRestWindshield.create(:active_record_car => car)
      assert_equal windshield, car.couch_rest_windshield

      engine = ActiveRecordEngine.create(:active_record_car => car)
      assert_equal engine, car.active_record_engine
    end

    should "be able to destroy the associated object when an object is destroyed" do
      ash_tray = MongoMapperAshTray.create
      dashboard = MongoMapperDashboard.create
      dashboard.ash_tray = ash_tray
      assert_equal dashboard.id.to_s, ash_tray.dashboard.id.to_s
      dashboard.destroy

      assert_nil MongoMapperAshTray.find(ash_tray.id)
      assert_nil MongoMapperDashboard.find(dashboard.id)
    end

    should "be able to delete the associated object when an object is destroyed" do
      dashboard = MongoMapperDashboard.create
      car = ActiveRecordCar.create
      car.mongo_mapper_dashboard = dashboard
      assert_equal car.id.to_s, dashboard.active_record_car_id.to_s
      car.destroy

      assert_nil ActiveRecordCar.find_by_id(car.id)
      assert_nil MongoMapperDashboard.find(dashboard.id)
    end

    should "be able to nullify the foreign key of the associated object when an object is destroyed" do
      engine = ActiveRecordEngine.create
      car = ActiveRecordCar.create
      car.active_record_engine = engine
      assert_equal car.id, engine.car_id
      car.destroy

      assert_nil ActiveRecordCar.find_by_id(car.id)
      engine = ActiveRecordEngine.find_by_id(engine.id)
      assert_not_nil engine
      assert_nil engine.car_id
    end
  end

end
