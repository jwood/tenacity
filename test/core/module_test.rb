require 'test_helper'

class ModuleTest < Test::Unit::TestCase

  context "A class with a belongs_to :account association" do
    person = Person.new

    should("should respond to account") { assert person.respond_to?(:account) }
    should("should respond to account=") { assert person.respond_to?(:account=) }
    should("should respond to account_id") { assert person.respond_to?(:account_id) }
  end

  context "A class with a has_many :transactions association" do
    person = Person.new

    should("should respond to transactions") { assert person.respond_to?(:transactions) }
    should("should respond to transactions=") { assert person.respond_to?(:transactions=) }
    should("should respond to transaction_ids") { assert person.respond_to?(:transaction_ids) }
  end

end

