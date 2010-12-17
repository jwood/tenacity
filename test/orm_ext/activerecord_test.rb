require 'test_helper'

class ActiveRecordTest < Test::Unit::TestCase

  context "The ActiveRecord extension" do
    setup do
      setup_fixtures
    end

    should "be able to find the object in the database" do
      car = ActiveRecordCar.create
      assert_equal car, ActiveRecordCar._t_find(car.id)
    end

    should "be able to find the associates of an object" do
      nut_1 = ActiveRecordNut.create(:mongo_mapper_wheel_id => 'abc123')
      nut_2 = ActiveRecordNut.create(:mongo_mapper_wheel_id => 'abc123')
      nut_3 = ActiveRecordNut.create(:mongo_mapper_wheel_id => 'xyz456')
      assert_set_equal [nut_1, nut_2], ActiveRecordNut._t_find_all_by_associate(:mongo_mapper_wheel_id, 'abc123')
    end

    should "be able to associate many objects with the given object" do
      nut = ActiveRecordNut.create
      nut._t_associate_many(:mongo_mapper_wheels, ['abc123', 'def456', 'ghi789'])
      rows = ActiveRecordNut.connection.execute("select mongo_mapper_wheel_id from active_record_nuts_mongo_mapper_wheels where active_record_nut_id = #{nut.id}")
      ids = []; rows.each { |r| ids << r[0] }; ids
      assert_set_equal ['abc123', 'def456', 'ghi789'], ids
    end

    should "be able to get the ids of the objects associated with the given object" do
      nut = ActiveRecordNut.create
      nut._t_associate_many(:mongo_mapper_wheels, ['abc123', 'def456', 'ghi789'])
      assert_set_equal ['abc123', 'def456', 'ghi789'], nut._t_get_associate_ids(:mongo_mapper_wheels)
    end
  end

end
