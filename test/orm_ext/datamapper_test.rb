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
      object_1 = DataMapperObject.create
      object_2 = DataMapperObject.create
      has_many_target_1 = DataMapperHasManyTarget.create(:data_mapper_object_id => object_1.id)
      has_many_target_2 = DataMapperHasManyTarget.create(:data_mapper_object_id => object_1.id)
      has_many_target_3 = DataMapperHasManyTarget.create(:data_mapper_object_id => object_2.id)
      assert_set_equal [has_many_target_1, has_many_target_2], DataMapperHasManyTarget._t_find_all_by_associate(:data_mapper_object_id, object_1.id)
    end

    should "return an empty array able to find the associates of an object" do
      assert_set_equal [], DataMapperHasManyTarget._t_find_all_by_associate(:data_mapper_object_id, '9999999999')
    end

    should "be able to reload an object from the database" do
      object = DataMapperHasOneTarget.create
      other_object = DataMapperObject.create
      object.mongo_mapper_object_id = other_object.id
      assert_equal other_object.id.to_s, object.mongo_mapper_object_id
      object._t_reload
      assert_nil object.mongo_mapper_object_id
    end

    should "return an empty array if there are no objects associated with the given object ids" do
      object = DataMapperObject.create
      assert_set_equal [], DataMapperHasManyTarget._t_find_all_ids_by_associate("data_mapper_object_id", object.id)
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

    should "save the object if it is dirty" do
      object = DataMapperObject.create
      object.prop = "something"
      assert object._t_save_if_dirty
    end

    should "return true for save if valid object is not dirty" do
      object = DataMapperObject.create
      assert object.save
    end

    should "not save the object if it is not dirty" do
      object = DataMapperObject.create
      DataMapperObject.any_instance.stubs(:save).raises(RuntimeError.new("should not have called this"))
      assert object._t_save_if_dirty
    end

    should "be able to successfully determine the id type" do
      assert_equal Integer, DataMapperObject._t_id_type
      assert_equal String, DataMapperObjectWithStringId._t_id_type

      class DataMapperObjectWithNoTable; include DataMapper::Resource; include Tenacity; end
      assert_equal Integer, DataMapperObjectWithNoTable._t_id_type
    end

    context "that works with t_has_many associations" do
      setup do
        @has_many_target_1 = DataMapperHasManyTarget.create
        @has_many_target_2 = DataMapperHasManyTarget.create
        @has_many_target_3 = DataMapperHasManyTarget.create
      end

      should "be able to get the ids of the objects associated with the given object" do
        object = DataMapperObject.create
        object.mongo_mapper_has_many_targets = [@has_many_target_1, @has_many_target_2, @has_many_target_3]
        object.save
        assert_set_equal [@has_many_target_1.id, @has_many_target_2.id, @has_many_target_3.id], DataMapperHasManyTarget._t_find_all_ids_by_associate("data_mapper_object_id", object.id)
      end
    end
  end

  private

  def association
    Tenacity::Association.new(:t_has_many, :data_mapper_has_many_targets, DataMapperObject)
  end

end
