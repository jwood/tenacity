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

    should "return nil if the specified id could not be found in the database" do
      assert_nil MongoMapperWheel._t_find('4d0e1224b28cdbfb72000042')
    end

    should "be able to find multiple objects in the database" do
      wheel_1 = MongoMapperWheel.create
      wheel_2 = MongoMapperWheel.create
      assert_set_equal [wheel_1, wheel_2], MongoMapperWheel._t_find_bulk([wheel_1.id, wheel_2.id, '4d0e1224b28cdbfb72000042'])
    end

    should "return an empty array if none of the specified object ids could be found in the database" do
      assert_equal [], MongoMapperWheel._t_find_bulk(['4d0e1224b28cdbfb72000042', '4d0e1224b28cdbfb72000043', '4d0e1224b28cdbfb72000044'])
    end

    should "be able to find the first associate of an object" do
      car = ActiveRecordCar.create
      wheel = MongoMapperWheel.create(:active_record_car_id => car.id.to_s)
      assert_equal wheel, MongoMapperWheel._t_find_first_by_associate(:active_record_car_id, car.id)
    end

    should "return nil if the first associate of an object could not be found" do
      assert_nil MongoMapperWheel._t_find_first_by_associate(:active_record_car_id, 12345)
    end

    should "be able to find the associates of an object" do
      wheel_1 = MongoMapperWheel.create(:active_record_car_id => '101')
      wheel_2 = MongoMapperWheel.create(:active_record_car_id => '101')
      wheel_3 = MongoMapperWheel.create(:active_record_car_id => '102')
      assert_set_equal [wheel_1, wheel_2], MongoMapperWheel._t_find_all_by_associate(:active_record_car_id, '101')
    end

    should "return an empty array if the object has no associates" do
      assert_equal [], MongoMapperWheel._t_find_all_by_associate(:active_record_car_id, 1234)
    end

    should "be able to reload an object from the database" do
      wheel = MongoMapperWheel.create
      wheel.active_record_car_id = 101
      assert_equal 101, wheel.active_record_car_id.to_i
      wheel.reload
      assert_equal '', wheel.active_record_car_id
    end

    should "be able to associate many objects with the given object" do
      nut_1 = ActiveRecordNut.create
      nut_2 = ActiveRecordNut.create
      nut_3 = ActiveRecordNut.create
      wheel = MongoMapperWheel.create
      wheel._t_associate_many(:active_record_nuts, [nut_1.id, nut_2.id, nut_3.id])
      assert_set_equal [nut_1.id, nut_2.id, nut_3.id], wheel.t_active_record_nut_ids
    end

    should "be able to get the ids of the objects associated with the given object" do
      nut_1 = ActiveRecordNut.create
      nut_2 = ActiveRecordNut.create
      nut_3 = ActiveRecordNut.create
      wheel = MongoMapperWheel.create
      wheel._t_associate_many(:active_record_nuts, [nut_1.id, nut_2.id, nut_3.id])
      assert_set_equal [nut_1.id, nut_2.id, nut_3.id], wheel._t_get_associate_ids(:active_record_nuts)
    end

    should "return an empty array when trying to fetch associate ids for an object with no associates" do
      wheel = MongoMapperWheel.create
      assert_equal [], wheel._t_get_associate_ids(:active_record_nuts)
    end

    should "be able to clear the associates of an object" do
      nut_1 = ActiveRecordNut.create
      nut_2 = ActiveRecordNut.create
      nut_3 = ActiveRecordNut.create
      wheel = MongoMapperWheel.create
      wheel._t_associate_many(:active_record_nuts, [nut_1.id, nut_2.id, nut_3.id])
      assert_set_equal [nut_1.id, nut_2.id, nut_3.id], wheel._t_get_associate_ids(:active_record_nuts)
      wheel._t_clear_associates(:active_record_nuts)
      assert_equal [], wheel._t_get_associate_ids(:active_record_nuts)
    end
  end

end
