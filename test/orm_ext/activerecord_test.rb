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

    should "return nil if the specified object cannot be found in the database" do
      assert_nil ActiveRecordCar._t_find(989782)
    end

    should "be able to find multiple objects in the database" do
      car = ActiveRecordCar.create
      car_2 = ActiveRecordCar.create
      assert_set_equal [car, car_2], ActiveRecordCar._t_find_bulk([car.id, car_2.id, 989823])
    end

    should "return an empty array if none of the specified ids could be found in the database" do
      assert_set_equal [], ActiveRecordNut._t_find_bulk([989823, 992111, 989771])
    end

    should "be able to find the first associate of an object" do
      mongo_mapper_dashboard = MongoMapperDashboard.create
      climate_control_unit = ActiveRecordClimateControlUnit.create(:mongo_mapper_dashboard_id => mongo_mapper_dashboard.id)
      assert_equal climate_control_unit, ActiveRecordClimateControlUnit._t_find_first_by_associate(:mongo_mapper_dashboard_id, mongo_mapper_dashboard.id)
    end

    should "return nil if unable to find the first associate of an object" do
      assert_nil ActiveRecordClimateControlUnit._t_find_first_by_associate(:mongo_mapper_dashboard_id, 'abc123')
    end

    should "be able to find all associates of an object" do
      nut_1 = ActiveRecordNut.create(:mongo_mapper_wheel_id => 'abc123')
      nut_2 = ActiveRecordNut.create(:mongo_mapper_wheel_id => 'abc123')
      nut_3 = ActiveRecordNut.create(:mongo_mapper_wheel_id => 'xyz456')
      assert_set_equal [nut_1, nut_2], ActiveRecordNut._t_find_all_by_associate(:mongo_mapper_wheel_id, 'abc123')
    end

    should "return an empty array able to find the associates of an object" do
      assert_set_equal [], ActiveRecordNut._t_find_all_by_associate(:mongo_mapper_wheel_id, 'abc123')
    end

    should "be able to reload an object from the database" do
      nut = ActiveRecordNut.create
      nut.mongo_mapper_wheel_id = 'abc123'
      nut.reload
      assert_equal '', nut.mongo_mapper_wheel_id
    end

    should "be able to clear the associates of a given object" do
      nut = ActiveRecordNut.create
      association = Tenacity::Association.new(:t_has_many, :mongo_mapper_wheels)
      nut._t_associate_many(association, ['abc123', 'def456', 'ghi789'])
      nut.save
      nut._t_clear_associates(association)
      assert_set_equal [], nut._t_get_associate_ids(association)
    end

    should "be able to associate many objects with the given object" do
      nut = ActiveRecordNut.create
      nut._t_associate_many(Tenacity::Association.new(:t_has_many, :mongo_mapper_wheels), ['abc123', 'def456', 'ghi789'])
      rows = ActiveRecordNut.connection.execute("select mongo_mapper_wheel_id from active_record_nuts_mongo_mapper_wheels where active_record_nut_id = #{nut.id}")
      ids = []; rows.each { |r| ids << r[0] }; ids
      assert_set_equal ['abc123', 'def456', 'ghi789'], ids
    end

    should "be able to get the ids of the objects associated with the given object" do
      nut = ActiveRecordNut.create
      association = Tenacity::Association.new(:t_has_many, :mongo_mapper_wheels)
      nut._t_associate_many(association, ['abc123', 'def456', 'ghi789'])
      assert_set_equal ['abc123', 'def456', 'ghi789'], nut._t_get_associate_ids(association)
    end

    should "return an empty array if there are no objects associated with the given object ids" do
      nut = ActiveRecordNut.create
      assert_set_equal [], nut._t_get_associate_ids(Tenacity::Association.new(:t_has_many, :mongo_mapper_wheels))
    end
  end

end
