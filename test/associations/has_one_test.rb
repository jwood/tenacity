require 'test_helper'

class HasOneTest < Test::Unit::TestCase

  context "A MongoMapper class with a has_one association to an ActiveRecord class" do
    setup do
      @climate_control_unit = ActiveRecordClimateControlUnit.create
      @dashboard = MongoMapperDashboard.create
    end

    should "be able to set and get the associated object" do
      @dashboard.active_record_climate_control_unit = @climate_control_unit
      assert_equal @climate_control_unit, MongoMapperDashboard.find(@dashboard.id).active_record_climate_control_unit
    end
  end

  context "An ActiveRecord class with a has_one association to a MongoMapper class" do
    setup do
      @dashboard = MongoMapperDashboard.create
      @car = ActiveRecordCar.create
    end

    should "be able to set and get the associated object" do
      @car.mongo_mapper_dashboard = @dashboard
      assert_equal @dashboard, ActiveRecordCar.find(@car.id).mongo_mapper_dashboard
    end
  end

end
