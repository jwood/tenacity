require 'test_helper'

class ModuleTest < Test::Unit::TestCase

  context "A class with a belongs_to :active_record_account association" do
    setup do
      setup_fixtures
      @person = MongoMapperPerson.new
    end

    should("respond to active_record_account") { assert @person.respond_to?(:active_record_account) }
    should("respond to active_record_account=") { assert @person.respond_to?(:active_record_account=) }
    should("respond to active_record_account_id") { assert @person.respond_to?(:active_record_account_id) }
  end

  context "A class with a has_many :active_record_transactions association" do
    setup do
      setup_fixtures
      @person = MongoMapperPerson.new
    end

    should("respond to active_record_transactions") { assert @person.respond_to?(:active_record_transactions) }
    should("respond to active_record_transactions=") { assert @person.respond_to?(:active_record_transactions=) }
    should("respond to active_record_transaction_ids") { assert @person.respond_to?(:active_record_transaction_ids) }
    should("respond to active_record_transaction_ids=") { assert @person.respond_to?(:active_record_transaction_ids=) }
  end

  context "The object returned by a has_many association" do
    setup do
      setup_fixtures
      @person = MongoMapperPerson.new
      @transactions = @person.active_record_transactions
    end

    should("respond to <<") { assert @transactions.respond_to?(:<<) }
    should("respond to delete") { assert @transactions.respond_to?(:delete) }
    should("respond to clear") { assert @transactions.respond_to?(:clear) }
    should("respond to empty?") { assert @transactions.respond_to?(:empty?) }
    should("respond to size") { assert @transactions.respond_to?(:size) }
  end

end

