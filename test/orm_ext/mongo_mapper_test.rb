require 'test_helper'

class MongoMapperTest < Test::Unit::TestCase

  context "The MongoMapper extension" do
    setup do
      setup_fixtures
    end

    should "be able to find the object in the database" do
      person = MongoMapperPerson.create
      assert_equal person, MongoMapperPerson._t_find(person.id)
    end

    should "be able to find the associates of an object" do
      person_1 = MongoMapperPerson.create(:active_record_account_id => 101)
      person_2 = MongoMapperPerson.create(:active_record_account_id => 101)
      person_3 = MongoMapperPerson.create(:active_record_account_id => 102)
      assert_set_equal [person_1, person_2], MongoMapperPerson._t_find_all_by_associate(:active_record_account_id, 101)
    end

    should "be able to associate many objects with the given object" do
      transaction_1 = ActiveRecordTransaction.create
      transaction_2 = ActiveRecordTransaction.create
      transaction_3 = ActiveRecordTransaction.create
      person = MongoMapperPerson.create
      person._t_associate_many(:active_record_transactions, [transaction_1.id, transaction_2.id, transaction_3.id])
      assert_set_equal [transaction_1.id, transaction_2.id, transaction_3.id], person._t_active_record_transaction_ids
    end

    should "be able to get the ids of the objects associated with the given object" do
      transaction_1 = ActiveRecordTransaction.create
      transaction_2 = ActiveRecordTransaction.create
      transaction_3 = ActiveRecordTransaction.create
      person = MongoMapperPerson.create
      person._t_associate_many(:active_record_transactions, [transaction_1.id, transaction_2.id, transaction_3.id])
      assert_set_equal [transaction_1.id, transaction_2.id, transaction_3.id], person._t_get_associate_ids(:active_record_transactions)
    end
  end

end
