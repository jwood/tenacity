require 'test_helper'

class MongoMapperTest < Test::Unit::TestCase

  context "The MongoMapper extension" do
    setup do
      setup_fixtures
      @person = MongoMapperPerson.create
    end

    should "be able to find the object in the database" do
      assert_equal @person, MongoMapperPerson._t_find(@person.id)
    end

    should "be able to find the associates of an object" do
      person_1 = MongoMapperPerson.create(:active_record_account_id => 101)
      person_2 = MongoMapperPerson.create(:active_record_account_id => 101)
      person_3 = MongoMapperPerson.create(:active_record_account_id => 102)
      assert_set_equal [person_1, person_2], MongoMapperPerson._t_find_associates(:active_record_account_id, 101)
    end

    should "be able to associate many objects with the given object" do
    end

    should "be able to get the ids of the objects associated with the given object" do
    end
  end

end
