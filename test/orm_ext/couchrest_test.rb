require 'test_helper'

class CouchRestTest < Test::Unit::TestCase

  context "The CouchRest extension" do
    setup do
      setup_couchdb_fixtures
    end

    should "be able to find the object in the database" do
      object = CouchRestObject.create({})
      assert_equal object, CouchRestObject._t_find(object.id)
    end

    should "return nil if the specified id could not be found in the database" do
      assert_nil CouchRestObject._t_find("abc123")
    end

    should "be able to find multiple objects in the database" do
      object_1 = CouchRestObject.create({})
      object_2 = CouchRestObject.create({})
      assert_set_equal [object_1, object_2], CouchRestObject._t_find_bulk([object_1.id, object_2.id, "abc123"])
    end

    should "return an empty array if unable to find the specified objects in the database" do
      assert_equal [], CouchRestObject._t_find_bulk(["abc123", "abc456", "abc789"])
    end

    should "be able to find the first associate of an object" do
      object = CouchRestObject.create({})
      target = CouchRestHasOneTarget.create(:couch_rest_object_id => object.id)
      assert_equal target, CouchRestHasOneTarget._t_find_first_by_associate(:couch_rest_object_id, object.id)
    end

    should "return nil if the first associate of an object could not be found" do
      assert_nil CouchRestHasOneTarget._t_find_first_by_associate(:couch_rest_object_id, 12345)
    end

    should "be able to find all associates of an object" do
      object = CouchRestObject.create({})
      target_1 = CouchRestHasManyTarget.create(:couch_rest_object_id => object.id)
      target_2 = CouchRestHasManyTarget.create(:couch_rest_object_id => object.id)
      target_3 = CouchRestHasManyTarget.create(:couch_rest_object_id => 'abc123')
      assert_set_equal [target_1, target_2], CouchRestHasManyTarget._t_find_all_by_associate(:couch_rest_object_id, object.id)
    end

    should "return an empty array if unable to find the associates of an object" do
      assert_set_equal [], CouchRestHasManyTarget._t_find_all_by_associate(:couch_rest_object_id, 'abc123')
    end

    should "be able to reload an object from the database" do
      object = CouchRestObject.create({"abc" => "123"})
      assert_equal "123", object["abc"]
      object["abc"] = "456"
      assert_equal "456", object["abc"]
      object._t_reload
      assert_equal "123", object["abc"]
    end

    should "be able to associate many objects with the given object" do
      target_1 = CouchRestHasManyTarget.create({})
      target_2 = CouchRestHasManyTarget.create({})
      target_3 = CouchRestHasManyTarget.create({})
      object = CouchRestObject.create({})
      object._t_associate_many(association, [target_1.id, target_2.id, target_3.id])
      assert_set_equal [target_1.id.to_s, target_2.id.to_s, target_3.id.to_s], object.t_couch_rest_has_many_target_ids
    end

    should "be able to get the ids of the objects associated with the given object" do
      target_1 = CouchRestHasManyTarget.create({})
      target_2 = CouchRestHasManyTarget.create({})
      target_3 = CouchRestHasManyTarget.create({})
      object = CouchRestObject.create({})

      object._t_associate_many(association, [target_1.id, target_2.id, target_3.id])
      assert_set_equal [target_1.id.to_s, target_2.id.to_s, target_3.id.to_s], object._t_get_associate_ids(association)
    end

    should "return an empty array when trying to fetch associate ids for an object with no associates" do
      object = CouchRestObject.create({})
      assert_equal [], object._t_get_associate_ids(association)
    end

    should "be able to clear the associates of an object" do
      target_1 = CouchRestHasManyTarget.create({})
      target_2 = CouchRestHasManyTarget.create({})
      target_3 = CouchRestHasManyTarget.create({})
      object = CouchRestObject.create({})

      object._t_associate_many(association, [target_1.id, target_2.id, target_3.id])
      assert_set_equal [target_1.id.to_s, target_2.id.to_s, target_3.id.to_s], object._t_get_associate_ids(association)
      object._t_clear_associates(association)
      assert_equal [], object._t_get_associate_ids(association)
    end

    should "be able to delete a set of objects, issuing their callbacks" do
      object_1 = CouchRestObject.create({})
      object_2 = CouchRestObject.create({})
      object_3 = CouchRestObject.create({})

      old_count = CouchRestObject.count
      CouchRestObject._t_delete([object_1.id, object_2.id, object_3.id])
      assert_equal old_count - 3, CouchRestObject.count
    end

    should "be able to delete a setup of objects, without issuing their callbacks" do
      object_1 = CouchRestObject.create({})
      object_2 = CouchRestObject.create({})
      object_3 = CouchRestObject.create({})

      old_count = CouchRestObject.count
      CouchRestObject._t_delete([object_1.id, object_2.id, object_3.id], false)
      assert_equal old_count - 3, CouchRestObject.count
    end
  end

  private

  def association
    Tenacity::Association.new(:t_has_many, :couch_rest_has_many_targets, CouchRestObject)
  end
end
