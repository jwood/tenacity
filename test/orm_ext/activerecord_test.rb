require 'test_helper'

class ActiveRecordTest < Test::Unit::TestCase

  context "The ActiveRecord extension" do
    account = ActiveRecordAccount.create

    should "be able to find the object in the database" do
      assert_equal account, ActiveRecordAccount._t_find(account.id)
    end
  end

end
