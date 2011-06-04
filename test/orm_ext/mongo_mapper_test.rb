require 'test_helper'

class MongoMapperTest < Test::Unit::TestCase

  context "The MongoMapper extension" do
    setup do
      setup_fixtures
    end

    should "be able to find the object in the database" do
      object = MongoMapperObject.create
      assert_equal object, MongoMapperObject._t_find(object.id)
    end

    should "return nil if the specified id could not be found in the database" do
      assert_nil MongoMapperObject._t_find('4d0e1224b28cdbfb72000042')
    end

    should "be able to find multiple objects in the database" do
      object_1 = MongoMapperObject.create
      object_2 = MongoMapperObject.create
      assert_set_equal [object_1, object_2], MongoMapperObject._t_find_bulk([object_1.id, object_2.id, '4d0e1224b28cdbfb72000042'])
    end

    should "return an empty array if none of the specified object ids could be found in the database" do
      assert_equal [], MongoMapperObject._t_find_bulk(['4d0e1224b28cdbfb72000042', '4d0e1224b28cdbfb72000043', '4d0e1224b28cdbfb72000044'])
    end

    should "be able to find the first associate of an object" do
      object = MongoMapperObject.create
      target = MongoMapperHasOneTarget.create(:mongo_mapper_object_id => object.id)
      assert_equal target, MongoMapperHasOneTarget._t_find_first_by_associate(:mongo_mapper_object_id, object.id)
    end

    should "return nil if the first associate of an object could not be found" do
      assert_nil MongoMapperHasOneTarget._t_find_first_by_associate(:mongo_mapper_object_id, 12345)
    end

    should "be able to find the associates of an object" do
      object_1 = MongoMapperObject.create
      object_2 = MongoMapperObject.create
      target_1 = MongoMapperHasOneTarget.create(:mongo_mapper_object_id => object_1.id)
      target_2 = MongoMapperHasOneTarget.create(:mongo_mapper_object_id => object_1.id)
      target_3 = MongoMapperHasOneTarget.create(:mongo_mapper_object_id => object_2.id)
      assert_set_equal [target_1, target_2], MongoMapperHasOneTarget._t_find_all_by_associate(:mongo_mapper_object_id, object_1.id)
    end

    should "return an empty array if the object has no associates" do
      assert_equal [], MongoMapperHasOneTarget._t_find_all_by_associate(:mongo_mapper_object_id, '1234')
    end

    should "be able to reload an object from the database" do
      target = MongoMapperHasOneTarget.create
      target.mongo_mapper_object_id = '101'
      assert_equal '101', target.mongo_mapper_object_id
      target._t_reload
      assert_nil target.mongo_mapper_object_id
    end

    should "be able to get the ids of the objects associated with the given object" do
      target_1 = MongoMapperHasManyTarget.create
      target_2 = MongoMapperHasManyTarget.create
      target_3 = MongoMapperHasManyTarget.create
      object = MongoMapperObject.create
      object.mongo_mapper_has_many_targets = [target_1, target_2, target_3]
      object.save

      assert_set_equal [target_1.id, target_2.id, target_3.id], MongoMapperHasManyTarget._t_find_all_ids_by_associate("mongo_mapper_object_id", object.id)
    end

    should "return an empty array when trying to fetch associate ids for an object with no associates" do
      object = MongoMapperObject.create
      assert_equal [], MongoMapperHasManyTarget._t_find_all_ids_by_associate("mongo_mapper_object_id", object.id)
    end

    should "be able to delete a set of objects, issuing their callbacks" do
      object_1 = MongoMapperObject.create
      object_2 = MongoMapperObject.create
      object_3 = MongoMapperObject.create

      old_count = MongoMapperObject.count
      MongoMapperObject._t_delete([object_1.id, object_2.id, object_3.id])
      assert_equal old_count - 3, MongoMapperObject.count
    end

    should "be able to delete a setup of objects, without issuing their callbacks" do
      object_1 = MongoMapperObject.create
      object_2 = MongoMapperObject.create
      object_3 = MongoMapperObject.create

      old_count = MongoMapperObject.count
      MongoMapperObject._t_delete([object_1.id, object_2.id, object_3.id], false)
      assert_equal old_count - 3, MongoMapperObject.count
    end
  end

  def association
    Tenacity::Association.new(:t_has_many, :mongo_mapper_has_many_targets, MongoMapperObject)
  end

end
