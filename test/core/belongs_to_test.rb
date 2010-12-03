require 'test_helper'

class BelongsToTest < Test::Unit::TestCase

  context "A class with a belongs_to association to an ActiveRecord class" do
    account = ActiveRecordAccount.create
    person = MongoMapperPerson.new

    should "be able to fetch the id of the associated object" do
      person.active_record_account_id = account.id
      person.save
      assert_equal account.id, MongoMapperPerson.find(person.id).active_record_account_id
    end

    should "be able to load the associated object" do
      person.active_record_account = account
      person.save
      assert_equal account.id, MongoMapperPerson.find(person.id).active_record_account_id
      assert_equal account, MongoMapperPerson.find(person.id).active_record_account
    end

    should "be able to load the associated object if all we have is the id" do
      person.active_record_account_id = account.id
      person.save
      assert_equal account, MongoMapperPerson.find(person.id).active_record_account
    end
  end

end
