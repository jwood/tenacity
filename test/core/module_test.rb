require 'test_helper'

class ModuleTest < Test::Unit::TestCase

  context "A class with a belongs_to :account association" do
    person = Person.new

    should("respond to account") { assert person.respond_to?(:account) }
    should("respond to account=") { assert person.respond_to?(:account=) }
    should("respond to account_id") { assert person.respond_to?(:account_id) }
  end

  context "A class with a has_many :transactions association" do
    person = Person.new

    should("respond to transactions") { assert person.respond_to?(:transactions) }
    should("respond to transactions=") { assert person.respond_to?(:transactions=) }
    should("respond to transaction_ids") { assert person.respond_to?(:transaction_ids) }
    should("respond to transaction_ids=") { assert person.respond_to?(:transaction_ids=) }
  end

  context "The object returned by a has_many association" do
    person = Person.new
    transactions = person.transactions

    should("respond to <<") { assert transactions.respond_to?(:<<) }
    should("respond to delete") { assert transactions.respond_to?(:delete) }
    should("respond to clear") { assert transactions.respond_to?(:clear) }
    should("respond to empty?") { assert transactions.respond_to?(:empty?) }
    should("respond to size") { assert transactions.respond_to?(:size) }
  end

end

