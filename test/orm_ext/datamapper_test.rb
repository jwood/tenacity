require 'test_helper'

class DataMapperTest < Test::Unit::TestCase

  context "The DataMapper extension" do
    setup do
      setup_fixtures
    end

    should "be able to find the object in the database" do
      object = DataMapperObject.create
      assert_equal object, DataMapperObject._t_find(object.id)
    end

    should "return nil if the specified object cannot be found in the database" do
      assert_nil DataMapperObject._t_find(989782)
    end

    should "be able to find multiple objects in the database" do
      object = DataMapperObject.create
      object_2 = DataMapperObject.create
      assert_set_equal [object, object_2], DataMapperObject._t_find_bulk([object.id, object_2.id, 989823])
    end

    should "return an empty array if none of the specified ids could be found in the database" do
      assert_set_equal [], DataMapperObject._t_find_bulk([989823, 992111, 989771])
    end

    should "be able to find the first associate of an object" do
      object = DataMapperObject.create
      has_one_target = DataMapperHasOneTarget.create(:data_mapper_object_id => object.id)
      assert_equal has_one_target, DataMapperHasOneTarget._t_find_first_by_associate(:data_mapper_object_id, object.id)
    end

    should "return nil if unable to find the first associate of an object" do
      assert_nil DataMapperHasOneTarget._t_find_first_by_associate(:data_mapper_object_id, '9999999')
    end

    should "be able to find all associates of an object" do
      object = DataMapperObject.create
      has_many_target_1 = DataMapperHasManyTarget.create(:data_mapper_object_id => object.id)
      has_many_target_2 = DataMapperHasManyTarget.create(:data_mapper_object_id => object.id)
      has_many_target_3 = DataMapperHasManyTarget.create(:data_mapper_object_id => '9999999')
      assert_set_equal [has_many_target_1, has_many_target_2], DataMapperHasManyTarget._t_find_all_by_associate(:data_mapper_object_id, object.id)
    end

    should "return an empty array able to find the associates of an object" do
      assert_set_equal [], DataMapperHasManyTarget._t_find_all_by_associate(:data_mapper_object_id, '9999999999')
    end

    should "be able to reload an object from the database" do
      object = DataMapperHasOneTarget.create
      other_object = MongoMapperObject.create
      object.mongo_mapper_object_id = other_object.id
      assert_equal other_object.id.to_s, object.mongo_mapper_object_id
      object.reload
      assert_equal '', object.mongo_mapper_object_id
    end

    should "return an empty array if there are no objects associated with the given object ids" do
      object = DataMapperObject.create
      assert_set_equal [], object._t_get_associate_ids(association)
    end

    should "be able to delete a set of objects, issuing their callbacks" do
      object_1 = DataMapperObject.create
      object_2 = DataMapperObject.create
      object_3 = DataMapperObject.create

      old_count = DataMapperObject.count
      DataMapperObject._t_delete([object_1.id, object_2.id, object_3.id])
      assert_equal old_count - 3, DataMapperObject.count
    end

    should "be able to delete a setup of objects, without issuing their callbacks" do
      object_1 = DataMapperObject.create
      object_2 = DataMapperObject.create
      object_3 = DataMapperObject.create

      old_count = DataMapperObject.count
      DataMapperObject._t_delete([object_1.id, object_2.id, object_3.id], false)
      assert_equal old_count - 3, DataMapperObject.count
    end

    context "that works with t_has_many associations" do
      setup do
        @has_many_target_1 = MongoMapperHasManyTarget.create
        @has_many_target_2 = MongoMapperHasManyTarget.create
        @has_many_target_3 = MongoMapperHasManyTarget.create
      end

      should "be able to clear the associates of a given object" do
        object = DataMapperObject.create
        object._t_associate_many(association, [@has_many_target_1.id, @has_many_target_2.id, @has_many_target_3.id])
        object.save
        object._t_clear_associates(association)
        assert_set_equal [], object._t_get_associate_ids(association)
      end

      should "be able to associate many objects with the given object" do
        object = DataMapperObject.create
        object._t_associate_many(association, [@has_many_target_1.id, @has_many_target_2.id, @has_many_target_3.id])
        rows = DataMapperObject.repository.adapter.select("select mongo_mapper_has_many_target_id from data_mapper_objects_mongo_mapper_has_many_targets where data_mapper_object_id = #{object.id}")
        assert_set_equal [@has_many_target_1.id.to_s, @has_many_target_2.id.to_s, @has_many_target_3.id.to_s], rows
      end

      should "be able to get the ids of the objects associated with the given object" do
        object = DataMapperObject.create
        object._t_associate_many(association, [@has_many_target_1.id, @has_many_target_2.id, @has_many_target_3.id])
        assert_set_equal [@has_many_target_1.id.to_s, @has_many_target_2.id.to_s, @has_many_target_3.id.to_s], object._t_get_associate_ids(association)
      end
    end
  end

  private

  def association
    Tenacity::Association.new(:t_has_many, :mongo_mapper_has_many_targets, DataMapperObject)
  end

end
