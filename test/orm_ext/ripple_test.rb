require 'test_helper'

require_ripple do
  class RippleTest < Test::Unit::TestCase

    context "The Ripple extension" do
      setup do
        setup_fixtures
      end

      should "be able to find the object in the database" do
        object = RippleObject.create
        assert_equal object, RippleObject._t_find(object.key)
      end

      should "return nil if the specified id could not be found in the database" do
        assert_nil RippleObject._t_find('something')
      end
    end
  end
end
