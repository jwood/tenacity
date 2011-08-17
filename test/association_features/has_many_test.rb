require 'test_helper'

class HasManyTest < Test::Unit::TestCase
  
  context "A class with a has_many conditional association to another class" do
    setup do
      setup_fixtures
      setup_couchdb_fixtures

      @car = ActiveRecordCar.create
      @driver_seet = ActiveRecordSeet.create(:back => false, :is_driver => true )
      @front_seets = [@driver_seet, ActiveRecordSeet.create(:back => false)]
      @back_seets = [ActiveRecordSeet.create(:back => true), ActiveRecordSeet.create(:back => true)]

      @car.active_record_front_seets = @front_seets
      @car.active_record_back_seets = @back_seets
      @car.save
    end

    should "memoize the conditional association" do
      assert_equal @driver_seet, @car.active_record_driver_seet(true)
      assert_equal @front_seets, @car.active_record_front_seets
      assert_equal @back_seets, @car.active_record_back_seets

      other_seets = [ActiveRecordSeet.create(:back => false), ActiveRecordSeet.create(:back => false)]
      assert_equal @front_seets, ActiveRecordCar.find(@car.id).active_record_front_seets
      ActiveRecordCar.find(@car.id).update_attribute(:active_record_front_seets, other_seets)
      assert_equal other_seets, ActiveRecordCar.find(@car.id).active_record_front_seets

      assert_equal @front_seets, @car.active_record_front_seets
      assert_equal other_seets, @car.active_record_front_seets(true)
    end
  end

  context "A class with a has_many association to another class" do
    setup do
      setup_fixtures
      setup_couchdb_fixtures

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
      assert_set_equal [door_1.id, door_2.id, door_3.id], ActiveRecordCar.find(car.id).couch_rest_door_ids
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

    should "not be able to modify an associated object if the readonly option is set" do
      car = ActiveRecordCar.create
      wheel_1 = MongoMapperWheel.create
      wheel_2 = MongoMapperWheel.create
      wheel_3 = MongoMapperWheel.create
      car.mongo_mapper_wheels = [wheel_1, wheel_2, wheel_3]
      car.save

      wheel = car.mongo_mapper_wheels.first
      wheel.prop = "value"
      assert_raises(Tenacity::ReadOnlyError) { wheel.save }
    end

    should "only return the number of results specified by the :limit option" do
      car = ActiveRecordCar.create
      wheel_1 = MongoMapperWheel.create
      wheel_2 = MongoMapperWheel.create
      wheel_3 = MongoMapperWheel.create
      wheel_4 = MongoMapperWheel.create
      wheel_5 = MongoMapperWheel.create
      wheel_6 = MongoMapperWheel.create
      wheel_7 = MongoMapperWheel.create
      wheel_8 = MongoMapperWheel.create
      car.mongo_mapper_wheels = [wheel_1, wheel_2, wheel_3, wheel_4, wheel_5, wheel_6, wheel_7, wheel_8]
      car.save

      sorted_wheels = car.mongo_mapper_wheels.sort { |a,b| a.id.to_s <=> b.id.to_s }
      sorted_wheel_ids = sorted_wheels.map { |wheel| wheel.id.to_s }

      assert_set_equal [sorted_wheels[0], sorted_wheels[1], sorted_wheels[2], sorted_wheels[3], sorted_wheels[4]],
        ActiveRecordCar.find(car.id).mongo_mapper_wheels
      assert_set_equal [sorted_wheel_ids[0], sorted_wheel_ids[1], sorted_wheel_ids[2], sorted_wheel_ids[3], sorted_wheel_ids[4]],
        ActiveRecordCar.find(car.id).mongo_mapper_wheel_ids
    end

    should "skip over the first group of results, as specified by the :offset option" do
      car = ActiveRecordCar.create
      window_1 = MongoMapperWindow.create
      window_2 = MongoMapperWindow.create
      window_3 = MongoMapperWindow.create
      window_4 = MongoMapperWindow.create
      window_5 = MongoMapperWindow.create
      window_6 = MongoMapperWindow.create
      window_7 = MongoMapperWindow.create
      window_8 = MongoMapperWindow.create
      window_9 = MongoMapperWindow.create
      car.mongo_mapper_windows = [window_1, window_2, window_3, window_4, window_5, window_6, window_7, window_8, window_9]
      car.save

      sorted_windows = car.mongo_mapper_windows.sort { |a,b| a.id.to_s <=> b.id.to_s }
      sorted_window_ids = sorted_windows.map { |window| window.id.to_s }

      assert_set_equal [sorted_windows[3], sorted_windows[4], sorted_windows[5], sorted_windows[6], sorted_windows[7]],
        ActiveRecordCar.find(car.id).mongo_mapper_windows
      assert_set_equal [sorted_window_ids[3], sorted_window_ids[4], sorted_window_ids[5], sorted_window_ids[6], sorted_window_ids[7]],
        ActiveRecordCar.find(car.id).mongo_mapper_window_ids
    end

    should "be able to store objects via their polymorphic interface" do
      circuit_board_1 = MongoMapperCircuitBoard.create
      circuit_board_2 = MongoMapperCircuitBoard.create
      circuit_board_3 = MongoMapperCircuitBoard.create
      engine = ActiveRecordEngine.create
      engine.diagnosable = [circuit_board_1, circuit_board_2, circuit_board_3]
      engine.save

      components = ActiveRecordEngine.find(engine.id).diagnosable
      assert_set_equal [circuit_board_1, circuit_board_2, circuit_board_3], components
      assert_set_equal ['ActiveRecordEngine', 'ActiveRecordEngine', 'ActiveRecordEngine'], components.map {|c| c.diagnosable_type}
    end

    context "with an a active t_belongs_to association that is not auto destroyed" do
      setup do
        @car = ActiveRecordCar.create
        window_1 = MongoMapperWindow.create
        window_2 = MongoMapperWindow.create
        window_3 = MongoMapperWindow.create
        window_4 = MongoMapperWindow.create
        window_5 = MongoMapperWindow.create
        window_6 = MongoMapperWindow.create
        window_7 = MongoMapperWindow.create
        window_8 = MongoMapperWindow.create
        window_9 = MongoMapperWindow.create
        @car.mongo_mapper_windows = [window_1, window_2, window_3, window_4, window_5, window_6, window_7, window_8, window_9]
        @car.save
      end

      should "should not eligible for deletion" do
        assert_raises(Tenacity::ObjectIdInUseError) { ActiveRecordCar._t_delete(@car.id) }
        assert_not_nil ActiveRecordCar._t_find(@car.id)
      end

      should "should be eligible for deletion if foreign key constraints are disabled" do
        Tenacity::Association.any_instance.stubs(:foreign_key_constraints_enabled?).returns(false)
        ActiveRecordCar._t_delete(@car.id)
        assert_nil ActiveRecordCar._t_find(@car.id)
      end
    end

    context "with an autosave association" do
      setup do
        @source = ActiveRecordObject.create
        @targets = [MongoMapperAutosaveTrueHasManyTarget.create(:prop => 'abc'), MongoMapperAutosaveTrueHasManyTarget.create(:prop => 'def')]
        @source.mongo_mapper_autosave_true_has_many_targets = @targets
        @source.save
        assert_equal 'abc', @source.mongo_mapper_autosave_true_has_many_targets(true).first.prop
      end

      should "save the associated object if autosave is true" do
        @source.mongo_mapper_autosave_true_has_many_targets.first.prop = 'xyz'
        @source.save
        @source.reload && @source.mongo_mapper_autosave_true_has_many_targets(true)
        assert_equal 'xyz', @source.mongo_mapper_autosave_true_has_many_targets.first.prop
      end

      should "destroy the associated object stored in a local variable if autosave is true and object is marked for destruction" do
        object = @source.mongo_mapper_autosave_true_has_many_targets.first
        object.mark_for_destruction
        assert object.marked_for_destruction?
        @source.save
        @source.reload && @source.mongo_mapper_autosave_true_has_many_targets(true)
        assert_equal 1, @source.mongo_mapper_autosave_true_has_many_targets.size
        assert_equal 'def', @source.mongo_mapper_autosave_true_has_many_targets.first.prop
      end

      should "destroy the associated object if autosave is true and object is marked for destruction" do
        @source.mongo_mapper_autosave_true_has_many_targets.first.mark_for_destruction
        assert @source.mongo_mapper_autosave_true_has_many_targets.first.marked_for_destruction?
        @source.save
        @source.reload && @source.mongo_mapper_autosave_true_has_many_targets(true)
        assert_equal 1, @source.mongo_mapper_autosave_true_has_many_targets.size
        assert_equal 'def', @source.mongo_mapper_autosave_true_has_many_targets.first.prop
      end
    end

    context "with a set of associates that need to be deleted" do
      setup do
        @new_car = ActiveRecordCar.create
        @door_1 = CouchRestDoor.create({})
        @door_2 = CouchRestDoor.create({})
        @door_3 = CouchRestDoor.create({})
        @new_car.couch_rest_doors = [@door_1, @door_2, @door_3]
        @new_car.save
      end

      should "be able to delete all associates" do
        assert_set_equal [@door_1, @door_2, @door_3], ActiveRecordCar.find(@new_car.id).couch_rest_doors
        old_count = CouchRestDoor.count
        @new_car.couch_rest_doors.delete_all
        assert_equal old_count - 3, CouchRestDoor.count
        assert_set_equal [], ActiveRecordCar.find(@new_car.id).couch_rest_doors
      end

      should "be able to destroy all associates" do
        assert_set_equal [@door_1, @door_2, @door_3], ActiveRecordCar.find(@new_car.id).couch_rest_doors
        old_count = CouchRestDoor.count
        @new_car.couch_rest_doors.destroy_all
        assert_equal old_count - 3, CouchRestDoor.count
        assert_set_equal [], ActiveRecordCar.find(@new_car.id).couch_rest_doors
      end

      context "the delete method" do
        should "not delete the object from the database if no dependent option is specified" do
          dashboard = MongoMapperDashboard.create
          vent_1 = MongoMapperVent.create
          vent_2 = MongoMapperVent.create
          vent_3 = MongoMapperVent.create
          dashboard.vents = [vent_1, vent_2, vent_3]
          dashboard.save
          assert_set_equal [vent_1, vent_2, vent_3], MongoMapperDashboard.find(dashboard.id).vents

          dashboard.vents.delete(vent_1)
          dashboard.save
          assert_set_equal [vent_2, vent_3], MongoMapperDashboard.find(dashboard.id).vents
          assert_not_nil MongoMapperVent.find(vent_1.id)
        end

        should "delete the associated object and issue callbacks if association is configured to :destroy dependents" do
          wheel_1 = MongoMapperWheel.create
          wheel_2 = MongoMapperWheel.create
          wheel_3 = MongoMapperWheel.create
          @new_car.mongo_mapper_wheels = [wheel_1, wheel_2, wheel_3]
          @new_car.save
          assert_set_equal [wheel_1, wheel_2, wheel_3], ActiveRecordCar.find(@new_car.id).mongo_mapper_wheels

          @new_car.mongo_mapper_wheels.delete(wheel_1)
          @new_car.save
          assert_set_equal [wheel_2, wheel_3], ActiveRecordCar.find(@new_car.id).mongo_mapper_wheels
          assert_nil MongoMapperWheel._t_find(wheel_1.id)
        end

        should "delete the associated object without issuing callbacks if association is configured to :delete_all dependents" do
          @new_car.couch_rest_doors.delete(@door_1)
          @new_car.save
          assert_set_equal [@door_2, @door_3], ActiveRecordCar.find(@new_car.id).couch_rest_doors
          assert_nil CouchRestDoor._t_find(@door_1.id)
        end
      end

      context "the clear method" do
        should "not delete the object from the database if no dependent option is specified" do
          dashboard = MongoMapperDashboard.create
          vent_1 = MongoMapperVent.create
          vent_2 = MongoMapperVent.create
          dashboard.vents = [vent_1, vent_2]
          dashboard.save
          assert_set_equal [vent_1, vent_2], MongoMapperDashboard.find(dashboard.id).vents

          dashboard.vents.clear
          dashboard.save
          assert_set_equal [], MongoMapperDashboard.find(dashboard.id).vents
          assert_not_nil MongoMapperVent.find(vent_1.id)
          assert_not_nil MongoMapperVent.find(vent_2.id)
        end

        should "delete the associated object and issue callbacks if association is configured to :destroy dependents" do
          wheel_1 = MongoMapperWheel.create
          wheel_2 = MongoMapperWheel.create
          @new_car.mongo_mapper_wheels = [wheel_1, wheel_2]
          @new_car.save
          assert_set_equal [wheel_1, wheel_2], ActiveRecordCar.find(@new_car.id).mongo_mapper_wheels

          @new_car.mongo_mapper_wheels.clear
          @new_car.save
          assert_set_equal [], ActiveRecordCar.find(@new_car.id).mongo_mapper_wheels
          assert_nil MongoMapperWheel._t_find(wheel_1.id)
          assert_nil MongoMapperWheel._t_find(wheel_2.id)
        end

        should "delete the associated object without issuing callbacks if association is configured to :delete_all dependents" do
          @new_car.couch_rest_doors.clear
          @new_car.save
          assert_set_equal [], ActiveRecordCar.find(@new_car.id).couch_rest_doors
          assert_nil CouchRestDoor._t_find(@door_1.id)
          assert_nil CouchRestDoor._t_find(@door_2.id)
          assert_nil CouchRestDoor._t_find(@door_3.id)
        end
      end
    end
  end

end
