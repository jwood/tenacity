require 'test_helper'

class CouchRestTest < Test::Unit::TestCase

  context "The CouchRest extension" do
    setup do
      setup_fixtures
    end

    should "be able to find the object in the database" do
      radio = CouchRestRadio.create({})
      assert_equal radio, CouchRestRadio._t_find(radio.id)
    end
  end
end
