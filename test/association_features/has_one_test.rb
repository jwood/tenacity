require 'test_helper'

class HasOneTest < Test::Unit::TestCase

  context "A class with a has_one association to another class" do
    setup do
      setup_fixtures
      setup_couchdb_fixtures

      @dashboard = MongoMapperDashboard.create
      @climate_control_unit = ActiveRecordClimateControlUnit.create(:mongo_mapper_dashboard => @dashboard)
    end

    should "memoize the association" do
      assert_equal @climate_control_unit, @dashboard.active_record_climate_control_unit

      other_climate_control_unit = ActiveRecordClimateControlUnit.create
      assert_equal @climate_control_unit, MongoMapperDashboard.find(@dashboard.id).active_record_climate_control_unit
      ActiveRecordClimateControlUnit.update(@climate_control_unit.id, :mongo_mapper_dashboard_id => nil)
      ActiveRecordClimateControlUnit.update(other_climate_control_unit.id, :mongo_mapper_dashboard_id => serialize_id(@dashboard))
      assert_equal other_climate_control_unit, MongoMapperDashboard.find(@dashboard.id).active_record_climate_control_unit

      assert_equal @climate_control_unit, @dashboard.active_record_climate_control_unit
      assert_equal other_climate_control_unit, @dashboard.active_record_climate_control_unit(true)
    end

    should "be able to specify the class name of the associated class" do
      dashboard = MongoMapperDashboard.create
      ash_tray = MongoMapperAshTray.create
      dashboard.ash_tray = ash_tray
      assert_equal ash_tray, dashboard.ash_tray
    end

    should "be able to specify the foreign key to use for the class" do
      car = ActiveRecordCar.create
      windshield = CouchRestWindshield.create(:active_record_car => car)
      assert_equal windshield, car.couch_rest_windshield

      engine = ActiveRecordEngine.create(:active_record_car => car)
      assert_equal engine, car.active_record_engine
    end

    should "not be able to modify the associated object if the readonly option is set" do
      car = ActiveRecordCar.create
      dashboard = MongoMapperDashboard.create(:active_record_car => car)
      dashboard = car.mongo_mapper_dashboard
      dashboard.prop = "value"
      assert_raises(Tenacity::ReadOnlyError) { dashboard.save }
    end

    should "save the associated object if autosave is true" do
      source = ActiveRecordObject.create
      target = MongoMapperAutosaveTrueHasOneTarget.new(:prop => 'abc')
      source.mongo_mapper_autosave_true_has_one_target = target
      source.save
      assert_equal 'abc', source.mongo_mapper_autosave_true_has_one_target.prop

      source.mongo_mapper_autosave_true_has_one_target.prop = 'xyz'
      source.save
      source.reload && source.mongo_mapper_autosave_true_has_one_target(true)
      assert_equal 'xyz', source.mongo_mapper_autosave_true_has_one_target.prop
    end

    should "not save the associated object upon assignment if autosave is false" do
      source = ActiveRecordObject.create
      target = MongoMapperAutosaveFalseHasOneTarget.new
      source.mongo_mapper_autosave_false_has_one_target = target

      source.save
      assert_nil MongoMapperAutosaveFalseHasOneTarget.first(:active_record_object_id => source.id)
    end

    should "destroy the associated object if autosave is true and object is marked for destruction" do
      source = ActiveRecordObject.create
      target = MongoMapperAutosaveTrueHasOneTarget.new
      source.mongo_mapper_autosave_true_has_one_target = target
      source.save
      assert_not_nil source.mongo_mapper_autosave_true_has_one_target(true)

      source.mongo_mapper_autosave_true_has_one_target.mark_for_destruction
      assert source.mongo_mapper_autosave_true_has_one_target.marked_for_destruction?
      source.save
      source.reload
      assert_nil source.mongo_mapper_autosave_true_has_one_target(true)
    end

    should "be able to store an object via its polymorphic interface" do
      circuit_board = MongoMapperCircuitBoard.create
      alternator = MongoMapperAlternator.create
      alternator.diagnosable = circuit_board
      alternator.save

      component = MongoMapperAlternator.find(alternator.id).diagnosable
      assert_equal circuit_board, component
      assert_equal 'MongoMapperAlternator', component.diagnosable_type
    end

    should "not be able to delete an object with an active t_belongs_to association" do
      assert_raises(Tenacity::ObjectIdInUseError) { MongoMapperDashboard._t_delete(@dashboard.id) }
      assert_not_nil MongoMapperDashboard._t_find(@dashboard.id)
    end

    should "be able to delete an object with an active t_belongs_to association if foreign key constraints are disabled" do
      Tenacity::Association.any_instance.stubs(:disable_foreign_key_constraints?).returns(:true)
      MongoMapperDashboard._t_delete(@dashboard.id)
      assert_nil MongoMapperDashboard._t_find(@dashboard.id)
    end
  end

end
