require 'test_helper'

require_toystore do
  class ToystoreTest < Test::Unit::TestCase

    context "The Toystore extension" do
      setup do
        setup_fixtures
      end

      should "be able to find the object in the database" do
        object = ToystoreObject.create
        assert_equal object, ToystoreObject._t_find(object.id)
      end

      should "return nil if the specified id could not be found in the database" do
        assert_nil ToystoreObject._t_find('4d0e1224b28cdbfb72000042')
      end

      should "be able to find multiple objects in the database" do
        object_1 = ToystoreObject.create
        object_2 = ToystoreObject.create
        assert_set_equal [object_1], ToystoreObject._t_find_bulk([object_1.id])
        assert_set_equal [object_1, object_2], ToystoreObject._t_find_bulk([object_1.id, object_2.id, '4d0e1224b28cdbfb72000042'])
      end

      should "return an empty array if none of the specified object ids could be found in the database" do
        assert_equal [], ToystoreObject._t_find_bulk(['4d0e1224b28cdbfb72000042', '4d0e1224b28cdbfb72000043', '4d0e1224b28cdbfb72000044'])
      end

      should "be able to find the first associate of an object" do
        object = ToystoreObject.create
        target = ToystoreHasOneTarget.create(:toystore_object_id => object.id)
        assert_equal target, ToystoreHasOneTarget._t_find_first_by_associate(:toystore_object_id, object.id)
      end

      should "return nil if the first associate of an object could not be found" do
        assert_nil ToystoreHasOneTarget._t_find_first_by_associate(:toystore_object_id, 12345)
      end

      should "be able to find the associates of an object" do
        object_1 = ToystoreObject.create
        object_2 = ToystoreObject.create
        target_1 = ToystoreHasOneTarget.create(:toystore_object_id => object_1.id)
        target_2 = ToystoreHasOneTarget.create(:toystore_object_id => object_1.id)
        target_3 = ToystoreHasOneTarget.create(:toystore_object_id => object_2.id)
        assert_set_equal [target_1, target_2], ToystoreHasOneTarget._t_find_all_by_associate(:toystore_object_id, object_1.id)
      end

      should "return an empty array if the object has no associates" do
        assert_equal [], ToystoreHasOneTarget._t_find_all_by_associate(:toystore_object_id, '1234')
      end

      should "be able to get the ids of the objects associated with the given object" do
        object = ToystoreObject.create
        target_1 = ToystoreHasManyTarget.create
        target_2 = ToystoreHasManyTarget.create
        target_3 = ToystoreHasManyTarget.create
        object.toystore_has_many_targets = [target_1, target_2, target_3]
        object.save

        assert_set_equal [target_1.id, target_2.id, target_3.id], ToystoreHasManyTarget._t_find_all_ids_by_associate(:toystore_object_id, object.id)
      end

      should "return an empty array when trying to fetch associate ids for an object with no associates" do
        object = ToystoreObject.create
        assert_set_equal [], ToystoreHasManyTarget._t_find_all_ids_by_associate(:toystore_object_id, object.id)
      end

      should "be able to reload an object from the database" do
        target = ToystoreHasOneTarget.create
        target.toystore_object_id = '101'
        assert_equal '101', target.toystore_object_id
        target._t_reload
        assert_nil target.toystore_object_id
      end

      should "be able to delete a set of objects, issuing their callbacks" do
        object_1 = ToystoreHasManyTarget.create
        object_2 = ToystoreHasManyTarget.create
        object_3 = ToystoreHasManyTarget.create

        assert_equal 3, ToystoreHasManyTarget.get_multi(object_1.id, object_2.id, object_3.id).compact.size
        ToystoreHasManyTarget._t_delete([object_1.id, object_2.id, object_3.id])
        assert_equal 0, ToystoreHasManyTarget.get_multi(object_1.id, object_2.id, object_3.id).compact.size
      end

      should "be able to delete a setup of objects, without issuing their callbacks" do
        object_1 = ToystoreHasManyTarget.create
        object_2 = ToystoreHasManyTarget.create
        object_3 = ToystoreHasManyTarget.create

        assert_equal 3, ToystoreHasManyTarget.get_multi(object_1.id, object_2.id, object_3.id).compact.size
        ToystoreHasManyTarget._t_delete([object_1.id, object_2.id, object_3.id], false)
        assert_equal 0, ToystoreHasManyTarget.get_multi(object_1.id, object_2.id, object_3.id).compact.size
      end

      should "save the object if it is dirty" do
        object = ToystoreObject.create
        object.prop = "something"
        assert object._t_save_if_dirty
      end

      should "not save the object if it is not dirty" do
        object = ToystoreObject.create
        assert !object._t_save_if_dirty
      end
    end

    def association
      Tenacity::Association.new(:t_has_many, :toystore_has_many_targets, ToystoreObject)
    end
  end
end
