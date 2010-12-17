require 'test_helper'

class HasOneTest < Test::Unit::TestCase

  context "A MongoMapper class with a has_one association to an ActiveRecord class" do
    setup do
      @auditor = ActiveRecordAuditor.create
      @ledger = MongoMapperLedger.create
    end

    should "be able to set and get the associated object" do
      @ledger.active_record_auditor = @auditor
      assert_equal @auditor, MongoMapperLedger.find(@ledger.id).active_record_auditor
    end
  end

  context "An ActiveRecord class with a has_one association to a MongoMapper class" do
    setup do
      @ledger = MongoMapperLedger.create
      @account = ActiveRecordAccount.create
    end

    should "be able to set and get the associated object" do
      @account.mongo_mapper_ledger = @ledger
      assert_equal @ledger, ActiveRecordAccount.find(@account.id).mongo_mapper_ledger
    end
  end

end
