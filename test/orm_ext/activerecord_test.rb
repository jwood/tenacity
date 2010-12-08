require 'test_helper'

class ActiveRecordTest < Test::Unit::TestCase

  context "The ActiveRecord extension" do
    setup do
      setup_fixtures
    end

    should "be able to find the object in the database" do
      account = ActiveRecordAccount.create
      assert_equal account, ActiveRecordAccount._t_find(account.id)
    end

    should "be able to find the associates of an object" do
      transaction_1 = ActiveRecordTransaction.create(:mongo_mapper_person_id => 'abc123')
      transaction_2 = ActiveRecordTransaction.create(:mongo_mapper_person_id => 'abc123')
      transaction_3 = ActiveRecordTransaction.create(:mongo_mapper_person_id => 'xyz456')
      assert_set_equal [transaction_1, transaction_2], ActiveRecordTransaction._t_find_all_by_associate(:mongo_mapper_person_id, 'abc123')
    end

    should "be able to associate many objects with the given object" do
      transaction = ActiveRecordTransaction.create
      transaction._t_associate_many(:mongo_mapper_people, ['abc123', 'def456', 'ghi789'])
      rows = ActiveRecordTransaction.connection.execute("select mongo_mapper_person_id from active_record_transactions_mongo_mapper_people where active_record_transaction_id = #{transaction.id}")
      ids = []; rows.each { |r| ids << r[0] }; ids
      assert_set_equal ['abc123', 'def456', 'ghi789'], ids
    end

    should "be able to get the ids of the objects associated with the given object" do
      transaction = ActiveRecordTransaction.create
      transaction._t_associate_many(:mongo_mapper_people, ['abc123', 'def456', 'ghi789'])
      assert_set_equal ['abc123', 'def456', 'ghi789'], transaction._t_get_associate_ids(:mongo_mapper_people)
    end
  end

end
