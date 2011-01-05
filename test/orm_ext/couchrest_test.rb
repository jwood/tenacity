require 'test_helper'

class CouchRestTest < Test::Unit::TestCase

  context "The CouchRest extension" do
    setup do
      setup_couchdb_fixtures
    end

    should "be able to find the object in the database" do
      radio = CouchRestRadio.create({})
      assert_equal radio, CouchRestRadio._t_find(radio.id)
    end

    should "return nil if the specified id could not be found in the database" do
      assert_nil CouchRestRadio._t_find("abc123")
    end

    should "be able to find multiple objects in the database" do
      radio_1 = CouchRestRadio.create({})
      radio_2 = CouchRestRadio.create({})
      assert_set_equal [radio_1, radio_2], CouchRestRadio._t_find_bulk([radio_1.id, radio_2.id, "abc123"])
    end

    should "return an empty array if unable to find the specified objects in the database" do
      assert_equal [], CouchRestRadio._t_find_bulk(["abc123", "abc456", "abc789"])
    end

    should "be able to find the first associate of an object" do
      dashboard = MongoMapperDashboard.create
      radio = CouchRestRadio.create(:mongo_mapper_dashboard_id => dashboard.id)
      assert_equal radio, CouchRestRadio._t_find_first_by_associate(:mongo_mapper_dashboard_id, dashboard.id)
    end

    should "return nil if the first associate of an object could not be found" do
      assert_nil CouchRestRadio._t_find_first_by_associate(:mongo_mapper_dashboard_id, 12345)
    end

    should "be able to find all associates of an object" do
      dashboard = MongoMapperDashboard.create
      radio_1 = CouchRestRadio.create(:mongo_mapper_dashboard_id => dashboard.id)
      radio_2 = CouchRestRadio.create(:mongo_mapper_dashboard_id => dashboard.id)
      radio_3 = CouchRestRadio.create(:mongo_mapper_dashboard_id => 'abc123')
      assert_set_equal [radio_1, radio_2], CouchRestRadio._t_find_all_by_associate(:mongo_mapper_dashboard_id, dashboard.id)
    end

    should "return an empty array if unable to find the associates of an object" do
      assert_equal [], CouchRestRadio._t_find_all_by_associate(:mongo_mapper_dashboard_id, 'abc123')
    end

    should "be able to reload an object from the database" do
      radio = CouchRestRadio.create({"abc" => "123"})
      assert_equal "123", radio["abc"]
      radio["abc"] = "456"
      assert_equal "456", radio["abc"]
      radio._t_reload
      assert_equal "123", radio["abc"]
    end

    should "be able to associate many objects with the given object" do
      button_1 = MongoMapperButton.create
      button_2 = MongoMapperButton.create
      button_3 = MongoMapperButton.create
      radio = CouchRestRadio.create({})
      radio._t_associate_many(Tenacity::Association.new(:mongo_mapper_buttons), [button_1.id, button_2.id, button_3.id])
      assert_set_equal [button_1.id.to_s, button_2.id.to_s, button_3.id.to_s], radio.t_mongo_mapper_button_ids
    end

    should "be able to get the ids of the objects associated with the given object" do
      button_1 = MongoMapperButton.create
      button_2 = MongoMapperButton.create
      button_3 = MongoMapperButton.create
      radio = CouchRestRadio.create({})

      association = Tenacity::Association.new(:mongo_mapper_buttons)
      radio._t_associate_many(association, [button_1.id, button_2.id, button_3.id])
      assert_set_equal [button_1.id.to_s, button_2.id.to_s, button_3.id.to_s], radio._t_get_associate_ids(association)
    end

    should "return an empty array when trying to fetch associate ids for an object with no associates" do
      radio = CouchRestRadio.create({})
      assert_equal [], radio._t_get_associate_ids(Tenacity::Association.new(:mongo_mapper_buttons))
    end

    should "be able to clear the associates of an object" do
      button_1 = MongoMapperButton.create
      button_2 = MongoMapperButton.create
      button_3 = MongoMapperButton.create
      radio = CouchRestRadio.create({})

      association = Tenacity::Association.new(:mongo_mapper_buttons)
      radio._t_associate_many(association, [button_1.id, button_2.id, button_3.id])
      assert_set_equal [button_1.id.to_s, button_2.id.to_s, button_3.id.to_s], radio._t_get_associate_ids(association)
      radio._t_clear_associates(association)
      assert_equal [], radio._t_get_associate_ids(association)
    end

  end
end
