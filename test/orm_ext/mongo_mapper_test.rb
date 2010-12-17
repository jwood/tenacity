require 'test_helper'

class MongoMapperTest < Test::Unit::TestCase

  context "The MongoMapper extension" do
    setup do
      setup_fixtures
    end

    should "be able to find the object in the database" do
      wheel = MongoMapperWheel.create
      assert_equal wheel, MongoMapperWheel._t_find(wheel.id)
    end

    should "be able to find the associates of an object" do
      wheel_1 = MongoMapperWheel.create(:active_record_car_id => 101)
      wheel_2 = MongoMapperWheel.create(:active_record_car_id => 101)
      wheel_3 = MongoMapperWheel.create(:active_record_car_id => 102)
      assert_set_equal [wheel_1, wheel_2], MongoMapperWheel._t_find_all_by_associate(:active_record_car_id, 101)
    end

    should "be able to associate many objects with the given object" do
      nut_1 = ActiveRecordNut.create
      nut_2 = ActiveRecordNut.create
      nut_3 = ActiveRecordNut.create
      wheel = MongoMapperWheel.create
      wheel._t_associate_many(:active_record_nuts, [nut_1.id, nut_2.id, nut_3.id])
      assert_set_equal [nut_1.id, nut_2.id, nut_3.id], wheel._t_active_record_nut_ids
    end

    should "be able to get the ids of the objects associated with the given object" do
      nut_1 = ActiveRecordNut.create
      nut_2 = ActiveRecordNut.create
      nut_3 = ActiveRecordNut.create
      wheel = MongoMapperWheel.create
      wheel._t_associate_many(:active_record_nuts, [nut_1.id, nut_2.id, nut_3.id])
      assert_set_equal [nut_1.id, nut_2.id, nut_3.id], wheel._t_get_associate_ids(:active_record_nuts)
    end
  end

end
