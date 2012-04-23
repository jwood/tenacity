require 'test_helper'

class ActiveRecordTest < Test::Unit::TestCase

  context "The ActiveRecord extension" do
    setup do
      setup_fixtures
    end

    should "be able to find the object in the database" do
      object = ActiveRecordObject.create
      assert_equal object, ActiveRecordObject._t_find(object.id)
    end

    should "return nil if the specified object cannot be found in the database" do
      assert_nil ActiveRecordObject._t_find(989782)
    end

    should "be able to find multiple objects in the database" do
      object = ActiveRecordObject.create
      object_2 = ActiveRecordObject.create
      assert_set_equal [object, object_2], ActiveRecordObject._t_find_bulk([object.id, object_2.id, 989823])
    end

    should "return an empty array if none of the specified ids could be found in the database" do
      assert_set_equal [], ActiveRecordObject._t_find_bulk([989823, 992111, 989771])
    end

    should "be able to find the first associate of an object" do
      object = ActiveRecordObject.create
      has_one_target = ActiveRecordHasOneTarget.create(:active_record_object_id => object.id)
      assert_equal has_one_target, ActiveRecordHasOneTarget._t_find_first_by_associate(:active_record_object_id, object.id)
    end

    should "return nil if unable to find the first associate of an object" do
      assert_nil ActiveRecordHasOneTarget._t_find_first_by_associate(:active_record_object_id, '9999999')
    end

    should "be able to find all associates of an object" do
      object_1 = ActiveRecordObject.create
      object_2 = ActiveRecordObject.create
      has_many_target_1 = ActiveRecordHasManyTarget.create(:active_record_object_id => object_1.id)
      has_many_target_2 = ActiveRecordHasManyTarget.create(:active_record_object_id => object_1.id)
      has_many_target_3 = ActiveRecordHasManyTarget.create(:active_record_object_id => object_2.id)
      assert_set_equal [has_many_target_1, has_many_target_2], ActiveRecordHasManyTarget._t_find_all_by_associate(:active_record_object_id, object_1.id)
    end

    should "return an empty array able to find the associates of an object" do
      assert_set_equal [], ActiveRecordHasManyTarget._t_find_all_by_associate(:active_record_object_id, '9999999999')
    end

    should "be able to reload an object from the database" do
      object = ActiveRecordHasOneTarget.create
      object.mongo_mapper_object_id = 'abc123'
      object._t_reload
      assert_nil object.mongo_mapper_object_id
    end

    should "be able to get the ids of the objects associated with the given object" do
      object = ActiveRecordObject.create!
      has_many_target_1 = ActiveRecordHasManyTarget.create!
      has_many_target_2 = ActiveRecordHasManyTarget.create!
      has_many_target_3 = ActiveRecordHasManyTarget.create!
      object.mongo_mapper_has_many_targets = [has_many_target_1, has_many_target_2, has_many_target_3]
      object.save

      assert_set_equal [has_many_target_1.id, has_many_target_2.id, has_many_target_3.id], ActiveRecordHasManyTarget._t_find_all_ids_by_associate("active_record_object_id", object.id)
    end

    should "return an empty array if there are no objects associated with the given object ids" do
      object = ActiveRecordObject.create
      assert_set_equal [], ActiveRecordHasManyTarget._t_find_all_ids_by_associate("active_record_object_id", object.id)
    end

    should "be able to delete a set of objects, issuing their callbacks" do
      object_1 = ActiveRecordObject.create
      object_2 = ActiveRecordObject.create
      object_3 = ActiveRecordObject.create

      old_count = ActiveRecordObject.count
      ActiveRecordObject._t_delete([object_1.id, object_2.id, object_3.id])
      assert_equal old_count - 3, ActiveRecordObject.count
    end

    should "be able to delete a setup of objects, without issuing their callbacks" do
      object_1 = ActiveRecordObject.create
      object_2 = ActiveRecordObject.create
      object_3 = ActiveRecordObject.create

      old_count = ActiveRecordObject.count
      ActiveRecordObject._t_delete([object_1.id, object_2.id, object_3.id], false)
      assert_equal old_count - 3, ActiveRecordObject.count
    end

    should "save the object if it is dirty" do
      object = ActiveRecordObject.create
      object.prop = "something"
      assert object._t_save_if_dirty
    end

    should "return true for save if valid object is not dirty" do
      object = ActiveRecordObject.create
      assert object.save
    end

    should "not save the object if it is not dirty" do
      object = ActiveRecordObject.create
      ActiveRecordObject.any_instance.stubs(:save).returns(false)
      assert object._t_save_if_dirty
    end

    should "be able to successfully determine the id type" do
      assert_equal Integer, ActiveRecordObject._t_id_type
      assert_equal String, ActiveRecordObjectWithStringId._t_id_type

      class ActiveRecordObjectWithNoTable < ActiveRecord::Base; include Tenacity; end
      assert_equal Integer, ActiveRecordObjectWithNoTable._t_id_type
    end
    
    should "successfully save if belongs_to another AR object which is assigned from a mongoid object" do
      org = ActiveRecordOrganization.create
      campus_hub = MongoidCampusHub.create
      campus_hub.active_record_organization = org
      campus_hub.save!
      user = ActiveRecordUser.new
      user.active_record_organization = campus_hub.active_record_organization
      assert user.save
      assert user.active_record_organization.save(:validate => false)
    end
  end

  private

  def association
    Tenacity::Association.new(:t_has_many, :active_record_has_many_targets, ActiveRecordObject)
  end

end
