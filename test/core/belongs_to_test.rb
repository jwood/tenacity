require 'test_helper'

class BelongsToTest < Test::Unit::TestCase

  context "A MongoMapper class with belongs_to association to an ActiveRecord class" do
    setup do
      @account = ActiveRecordAccount.create
      @person = MongoMapperPerson.new
    end

    should "be able to fetch the id of the associated object" do
      @person.active_record_account_id = @account.id
      @person.save
      assert_equal @account.id, MongoMapperPerson.find(@person.id).active_record_account_id
    end

    should "be able to load the associated object" do
      @person.active_record_account = @account
      @person.save
      assert_equal @account.id, MongoMapperPerson.find(@person.id).active_record_account_id
      assert_equal @account, MongoMapperPerson.find(@person.id).active_record_account
    end

    should "be able to load the associated object if all we have is the id" do
      @person.active_record_account_id = @account.id
      @person.save
      assert_equal @account, MongoMapperPerson.find(@person.id).active_record_account
    end
  end

  context "An ActiveRecord class with belongs_to association to a MongoMapper class" do
    setup do
      @ledger = MongoMapperLedger.create
      @transaction = ActiveRecordTransaction.new
    end

    should "be able to fetch the id of the associated object" do
      @transaction.mongo_mapper_ledger_id = @ledger.id
      @transaction.save
      assert_equal @ledger.id.to_s, ActiveRecordTransaction.find(@transaction.id).mongo_mapper_ledger_id
    end

    should "be able to load the associated object" do
      @transaction.mongo_mapper_ledger = @ledger
      @transaction.save
      assert_equal @ledger.id.to_s, ActiveRecordTransaction.find(@transaction.id).mongo_mapper_ledger_id
      assert_equal @ledger, ActiveRecordTransaction.find(@transaction.id).mongo_mapper_ledger
    end

    should "be be able to load the associated object if all we have is the id" do
      @transaction.mongo_mapper_ledger_id = @ledger.id
      @transaction.save
      assert_equal @ledger, ActiveRecordTransaction.find(@transaction.id).mongo_mapper_ledger
    end
  end

end
