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
  end

  context "A MongoMapper class with a has_one association to an ActiveRecord class" do
    setup do
      setup_fixtures
      @climate_control_unit = ActiveRecordClimateControlUnit.create
      @dashboard = MongoMapperDashboard.create
    end

    should "be able to set and get the associated object" do
      @dashboard.active_record_climate_control_unit = @climate_control_unit
      assert_equal @climate_control_unit, MongoMapperDashboard.find(@dashboard.id).active_record_climate_control_unit
    end

    should "return nil if no association is set" do
      assert_nil MongoMapperDashboard.find(@dashboard.id).active_record_climate_control_unit
    end
  end

  context "An ActiveRecord class with a has_one association to a MongoMapper class" do
    setup do
      setup_fixtures
      @dashboard = MongoMapperDashboard.create
      @car = ActiveRecordCar.create
    end

    should "be able to set and get the associated object" do
      @car.mongo_mapper_dashboard = @dashboard
      assert_equal @dashboard, ActiveRecordCar.find(@car.id).mongo_mapper_dashboard
    end

    should "return nil if no association is set" do
      assert_nil ActiveRecordCar.find(@car.id).mongo_mapper_dashboard
    end
  end

end
