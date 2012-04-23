require 'test_helper'

require_mongoid do
  class MongoidTest < Test::Unit::TestCase

    context "The Mongoid extension" do
      setup do
        setup_fixtures
      end

      should "be able to find the object in the database" do
        object = MongoidObject.create
        assert_equal object, MongoidObject._t_find(object.id)
      end

      should "return nil if the specified id could not be found in the database" do
        assert_nil MongoidObject._t_find('4d0e1224b28cdbfb72000042')
      end

      should "be able to find multiple objects in the database" do
        object_1 = MongoidObject.create
        object_2 = MongoidObject.create
        assert_set_equal [object_1, object_2], MongoidObject._t_find_bulk([object_1.id, object_2.id, '4d0e1224b28cdbfb72000042'])
      end

      should "return an empty array if none of the specified object ids could be found in the database" do
        assert_equal [], MongoidObject._t_find_bulk(['4d0e1224b28cdbfb72000042', '4d0e1224b28cdbfb72000043', '4d0e1224b28cdbfb72000044'])
      end

      should "be able to find the first associate of an object" do
        object = MongoidObject.create
        target = MongoidHasOneTarget.create(:mongoid_object_id => object.id)
        assert_equal target, MongoidHasOneTarget._t_find_first_by_associate(:mongoid_object_id, object.id)
      end

      should "return nil if the first associate of an object could not be found" do
        assert_nil MongoidHasOneTarget._t_find_first_by_associate(:mongoid_object_id, 12345)
      end

      should "be able to find the associates of an object" do
        object_1 = MongoidObject.create
        object_2 = MongoidObject.create
        target_1 = MongoidHasOneTarget.create(:mongoid_object_id => object_1.id)
        target_2 = MongoidHasOneTarget.create(:mongoid_object_id => object_1.id)
        target_3 = MongoidHasOneTarget.create(:mongoid_object_id => object_2.id)
        assert_set_equal [target_1, target_2], MongoidHasOneTarget._t_find_all_by_associate(:mongoid_object_id, object_1.id)
      end

      should "return an empty array if the object has no associates" do
        assert_equal [], MongoidHasOneTarget._t_find_all_by_associate(:mongoid_object_id, '1234')
      end

      should "be able to reload an object from the database" do
        target = MongoidHasOneTarget.create
        target.mongoid_object_id = '101'
        assert_equal '101', target.mongoid_object_id
        target._t_reload
        assert_nil target.mongoid_object_id
      end

      should "be able to get the ids of the objects associated with the given object" do
        target_1 = MongoidHasManyTarget.create
        target_2 = MongoidHasManyTarget.create
        target_3 = MongoidHasManyTarget.create
        object = MongoidObject.create
        object.mongoid_has_many_targets = [target_1, target_2, target_3]
        object.save

        assert_set_equal [target_1.id, target_2.id, target_3.id], MongoidHasManyTarget._t_find_all_ids_by_associate("mongoid_object_id", object.id)
      end

      should "return an empty array when trying to fetch associate ids for an object with no associates" do
        object = MongoidObject.create
        assert_equal [], MongoidHasManyTarget._t_find_all_ids_by_associate("mongoid_object_id", object.id)
      end

      should "be able to delete a set of objects, issuing their callbacks" do
        object_1 = MongoidObject.create
        object_2 = MongoidObject.create
        object_3 = MongoidObject.create

        old_count = MongoidObject.count
        MongoidObject._t_delete([object_1.id, object_2.id, object_3.id])
        assert_equal old_count - 3, MongoidObject.count
      end

      should "be able to delete a setup of objects, without issuing their callbacks" do
        object_1 = MongoidObject.create
        object_2 = MongoidObject.create
        object_3 = MongoidObject.create

        old_count = MongoidObject.count
        MongoidObject._t_delete([object_1.id, object_2.id, object_3.id], false)
        assert_equal old_count - 3, MongoidObject.count
      end

      should "save the object if it is dirty" do
        object = MongoidObject.create
        object.prop = "something"
        assert object._t_save_if_dirty
      end

      should "return true for save if valid object is not dirty" do
        object = MongoidObject.create
        assert object.save
      end
      
      should "not save the object if it is not dirty" do
        object = MongoidObject.create
        MongoidObject.any_instance.stubs(:save).returns(false)
        assert object._t_save_if_dirty
      end
    end

    def association
      Tenacity::Association.new(:t_has_many, :mongoid_has_many_targets, MongoidObject)
    end

  end
end
