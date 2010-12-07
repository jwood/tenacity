require 'test_helper'

class HasManyTest < Test::Unit::TestCase

  context "An ActiveRecord class with a has_many association to a MongoMapper class" do
    MongoMapperPerson.delete_all
    account = ActiveRecordAccount.create
    person_1 = MongoMapperPerson.create
    person_2 = MongoMapperPerson.create
    person_3 = MongoMapperPerson.create

    should "be able to set the associated objects" do
      account.mongo_mapper_people = [person_1, person_2, person_3]
      account.save
      assert_set_equal [person_1, person_2, person_3], ActiveRecordAccount.find(account.id).mongo_mapper_people
    end
  end

  context "A MongoMapper class with a has_many association to an ActiveRecord class" do
    MongoMapperPerson.delete_all
    person = MongoMapperPerson.create
    transaction_1 = ActiveRecordTransaction.create
    transaction_2 = ActiveRecordTransaction.create
    transaction_3 = ActiveRecordTransaction.create

    should "be able to set the associated objects" do
      person.active_record_transactions = [transaction_1, transaction_2, transaction_3]
      person.save
      assert_set_equal [transaction_1, transaction_2, transaction_3], MongoMapperPerson.find(person.id).active_record_transactions
    end
  end

end
