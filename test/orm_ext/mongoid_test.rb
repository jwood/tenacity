require_mongoid do
  require 'test_helper'

  class MongoidTest < Test::Unit::TestCase

    context "The Mongoid extension" do
      setup do
        setup_fixtures
      end

      should "be able to find the object in the database" do
        alternator = MongoidAlternator.create
        assert_equal alternator, MongoidAlternator._t_find(alternator.id)
      end

      should "return nil if the specified id could not be found in the database" do
        assert_nil MongoidAlternator._t_find('4d0e1224b28cdbfb72000042')
      end

      should "be able to find multiple objects in the database" do
        alternator_1 = MongoidAlternator.create
        alternator_2 = MongoidAlternator.create
        assert_set_equal [alternator_1, alternator_2], MongoidAlternator._t_find_bulk([alternator_1.id, alternator_2.id, '4d0e1224b28cdbfb72000042'])
      end

      should "return an empty array if none of the specified object ids could be found in the database" do
        assert_equal [], MongoidAlternator._t_find_bulk(['4d0e1224b28cdbfb72000042', '4d0e1224b28cdbfb72000043', '4d0e1224b28cdbfb72000044'])
      end

      should "be able to find the first associate of an object" do
        engine = ActiveRecordEngine.create
        alternator = MongoidAlternator.create(:active_record_engine_id => engine.id.to_s)
        assert_equal alternator, MongoidAlternator._t_find_first_by_associate(:active_record_engine_id, engine.id)
      end

      should "return nil if the first associate of an object could not be found" do
        assert_nil MongoidAlternator._t_find_first_by_associate(:active_record_engine_id, 12345)
      end

      should "be able to find the associates of an object" do
        alternator_1 = MongoidAlternator.create(:active_record_engine_id => '101')
        alternator_2 = MongoidAlternator.create(:active_record_engine_id => '101')
        alternator_3 = MongoidAlternator.create(:active_record_engine_id => '102')
        assert_set_equal [alternator_1, alternator_2], MongoidAlternator._t_find_all_by_associate(:active_record_engine_id, '101')
      end

      should "return an empty array if the object has no associates" do
        assert_equal [], MongoidAlternator._t_find_all_by_associate(:active_record_engine_id, 1234)
      end

      should "be able to reload an object from the database" do
        alternator = MongoidAlternator.create
        alternator.active_record_engine_id = 101
        assert_equal 101, alternator.active_record_engine_id.to_i
        alternator.reload
        assert_equal '', alternator.active_record_engine_id
      end

      should "be able to associate many objects with the given object" do
        coil_1 = MongoMapperCoil.create
        coil_2 = MongoMapperCoil.create
        coil_3 = MongoMapperCoil.create
        alternator = MongoidAlternator.create
        alternator._t_associate_many(association, [coil_1.id, coil_2.id, coil_3.id])
        assert_set_equal [coil_1.id.to_s, coil_2.id.to_s, coil_3.id.to_s], alternator.t_mongo_mapper_coil_ids
      end

      should "be able to get the ids of the objects associated with the given object" do
        coil_1 = MongoMapperCoil.create
        coil_2 = MongoMapperCoil.create
        coil_3 = MongoMapperCoil.create
        alternator = MongoidAlternator.create

        alternator._t_associate_many(association, [coil_1.id, coil_2.id, coil_3.id])
        assert_set_equal [coil_1.id.to_s, coil_2.id.to_s, coil_3.id.to_s], alternator._t_get_associate_ids(association)
      end

      should "return an empty array when trying to fetch associate ids for an object with no associates" do
        alternator = MongoidAlternator.create
        assert_equal [], alternator._t_get_associate_ids(association)
    end

    should "be able to clear the associates of an object" do
      coil_1 = MongoMapperCoil.create
      coil_2 = MongoMapperCoil.create
      coil_3 = MongoMapperCoil.create
      alternator = MongoidAlternator.create

      alternator._t_associate_many(association, [coil_1.id, coil_2.id, coil_3.id])
      assert_set_equal [coil_1.id.to_s, coil_2.id.to_s, coil_3.id.to_s], alternator._t_get_associate_ids(association)
      alternator._t_clear_associates(association)
      assert_equal [], alternator._t_get_associate_ids(association)
    end

    should "be able to delete a set of objects, issuing their callbacks" do
      alternator_1 = MongoidAlternator.create(:active_record_engine_id => '101')
      alternator_2 = MongoidAlternator.create(:active_record_engine_id => '101')
      alternator_3 = MongoidAlternator.create(:active_record_engine_id => '102')

      old_count = MongoidAlternator.count
      MongoidAlternator._t_delete([alternator_1.id, alternator_2.id, alternator_3.id])
      assert_equal old_count - 3, MongoidAlternator.count
    end

    should "be able to delete a setup of objects, without issuing their callbacks" do
      alternator_1 = MongoidAlternator.create(:active_record_engine_id => '101')
      alternator_2 = MongoidAlternator.create(:active_record_engine_id => '101')
      alternator_3 = MongoidAlternator.create(:active_record_engine_id => '102')

      old_count = MongoidAlternator.count
      MongoidAlternator._t_delete([alternator_1.id, alternator_2.id, alternator_3.id], false)
      assert_equal old_count - 3, MongoidAlternator.count
    end
  end

  def association
    Tenacity::Association.new(:t_has_many, :mongo_mapper_coils, MongoidAlternator)
  end

end
end
