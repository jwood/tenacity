require 'test_helper'

class BelongsToTest < Test::Unit::TestCase

  context "A class with a belongs_to association" do
    account = Account.create
    person = Person.new

    should "be able to fetch the id of the associated object" do
      person.account_id = account.id
      assert_equal account.id, person.account_id
    end

    should "be able to load the associated object" do
      person.account = account
      assert_equal account.id, person.account_id
      assert_equal account, person.account
    end

    should "be able to load the associated object if all we have is the id" do
      person.account_id = account.id
      assert_equal account, person.account
    end
  end

end
