require 'test_helper'

class HasOneTest < Test::Unit::TestCase

  context "A class with a has_one association to another class" do
    setup do
      setup_fixtures
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
  end

end
