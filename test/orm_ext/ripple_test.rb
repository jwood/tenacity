require 'test_helper'

require_ripple do
  class RippleTest < Test::Unit::TestCase

    context "The Ripple extension" do
      setup do
        setup_ripple_fixtures
      end

      should "be able to find the object in the database" do
        object = RippleObject.create
        assert_equal object, RippleObject._t_find(object.id)
      end

      should "return nil if the specified id could not be found in the database" do
        assert_nil RippleObject._t_find('something')
      end

      should "be able to find multiple objects in the database" do
        object_1 = RippleObject.create
        object_2 = RippleObject.create
        assert_set_equal [object_1, object_2], RippleObject._t_find_bulk([object_1.id, object_2.id, 'bogus_key'])
      end

      should "return an empty array if none of the specified object ids could be found in the database" do
        assert_equal [], RippleObject._t_find_bulk(['bogus_key_1', 'bogus_key_2', 'bogus_key_3'])
      end

      should "be able to find the first associate of an object" do
        object = RippleObject.create
        target = RippleHasOneTarget.create(:ripple_object_id => object.id)
        assert_equal target, RippleHasOneTarget._t_find_first_by_associate(:ripple_object_id, object.id)
      end

      should "return nil if the first associate of an object could not be found" do
        assert_nil RippleHasOneTarget._t_find_first_by_associate(:ripple_object_id, 12345)
      end

      should "be able to find the associates of an object" do
        object_1 = RippleObject.create
        object_2 = RippleObject.create
        target_1 = RippleHasOneTarget.create(:ripple_object => object_1)
        target_2 = RippleHasOneTarget.create(:ripple_object => object_1)
        target_3 = RippleHasOneTarget.create(:ripple_object => object_2)
        assert_set_equal [target_1, target_2], RippleHasOneTarget._t_find_all_by_associate(:ripple_object_id, object_1.id)
      end

      should "return an empty array if the object has no associates" do
        assert_equal [], RippleHasOneTarget._t_find_all_by_associate(:ripple_object_id, '1234')
      end

      should "be able to reload an object from the database" do
        target = RippleHasOneTarget.create
        target.ripple_object_id = '101'
        assert_equal '101', target.ripple_object_id
        target._t_reload
        assert_nil target.ripple_object_id
      end

      should "be able to associate many objects with the given object" do
        target_1 = RippleHasManyTarget.create
        target_2 = RippleHasManyTarget.create
        target_3 = RippleHasManyTarget.create
        object = RippleObject.create
        object._t_associate_many(association, [target_1.id, target_2.id, target_3.id])
        assert_set_equal [target_1.id, target_2.id, target_3.id], object.t_ripple_has_many_target_ids
      end

      should "be able to get the ids of the objects associated with the given object" do
        target_1 = RippleHasManyTarget.create
        target_2 = RippleHasManyTarget.create
        target_3 = RippleHasManyTarget.create
        object = RippleObject.create

        object._t_associate_many(association, [target_1.id, target_2.id, target_3.id])
        assert_set_equal [target_1.id, target_2.id, target_3.id], object._t_get_associate_ids(association)
      end

      should "return an empty array when trying to fetch associate ids for an object with no associates" do
        object = RippleObject.create
        assert_equal [], object._t_get_associate_ids(association)
      end

      should "be able to clear the associates of an object" do
        target_1 = RippleHasManyTarget.create
        target_2 = RippleHasManyTarget.create
        target_3 = RippleHasManyTarget.create
        object = RippleObject.create

        object._t_associate_many(association, [target_1.id, target_2.id, target_3.id])
        assert_set_equal [target_1.id, target_2.id, target_3.id], object._t_get_associate_ids(association)
        object._t_clear_associates(association)
        assert_equal [], object._t_get_associate_ids(association)
      end

      should "be able to delete a set of objects, issuing their callbacks" do
        object_1 = RippleObject.create
        object_2 = RippleObject.create
        object_3 = RippleObject.create

        assert RippleObject.bucket.exist?(object_1.id)
        assert RippleObject.bucket.exist?(object_2.id)
        assert RippleObject.bucket.exist?(object_3.id)
        RippleObject._t_delete([object_1.id, object_2.id, object_3.id])
        assert !RippleObject.bucket.exist?(object_1.id)
        assert !RippleObject.bucket.exist?(object_2.id)
        assert !RippleObject.bucket.exist?(object_3.id)
      end

      should "be able to delete a setup of objects, without issuing their callbacks" do
        object_1 = RippleObject.create
        object_2 = RippleObject.create
        object_3 = RippleObject.create

        assert RippleObject.bucket.exist?(object_1.id)
        assert RippleObject.bucket.exist?(object_2.id)
        assert RippleObject.bucket.exist?(object_3.id)
        RippleObject._t_delete([object_1.id, object_2.id, object_3.id], false)
        assert !RippleObject.bucket.exist?(object_1.id)
        assert !RippleObject.bucket.exist?(object_2.id)
        assert !RippleObject.bucket.exist?(object_3.id)
      end

      should "create associate indexes when source object is saved" do
        target_1 = RippleHasManyTarget.create
        target_2 = RippleHasManyTarget.create
        target_3 = RippleHasManyTarget.create
        object = RippleObject.create
        object.ripple_has_many_targets = [target_1, target_2, target_3]
        object.save

        bucket = ::Ripple.client.bucket('tenacity_test_ripple_has_many_target_ripple_object_id')
        assert_set_equal [target_1.id, target_2.id, target_3.id], bucket.get(object.id).data
      end

      should "destroy associate indexes when source object is saved" do
        target_1 = RippleHasManyTarget.create
        target_2 = RippleHasManyTarget.create
        target_3 = RippleHasManyTarget.create
        object = RippleObject.create
        object.ripple_has_many_targets = [target_1, target_2, target_3]
        object.save

        bucket = ::Ripple.client.bucket('tenacity_test_ripple_has_many_target_ripple_object_id')
        assert_set_equal [target_1.id, target_2.id, target_3.id], bucket.get(object.id).data
        target_2.destroy
        assert_set_equal [target_1.id, target_3.id], bucket.get(object.id).data

        target_1.destroy
        target_3.destroy
        assert_set_equal [], bucket.get(object.id).data
      end
    end

    def association
      Tenacity::Association.new(:t_has_many, :ripple_has_many_targets, RippleObject)
    end
  end
end
