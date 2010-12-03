require 'test_helper'

class MongoMapperTest < Test::Unit::TestCase

  context "The MongoMapper extension" do
    person = MongoMapperPerson.create

    should "be able to find the object in the database" do
      assert_equal person, MongoMapperPerson._t_find(person.id)
    end
  end

end
