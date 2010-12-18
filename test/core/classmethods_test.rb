require 'test_helper'

class ClassmethodsTest < Test::Unit::TestCase

  context "A class with a belongs_to :active_record_car association" do
    setup do
      setup_fixtures
      @wheel = MongoMapperWheel.new
    end

    should("respond to active_record_car") { assert @wheel.respond_to?(:active_record_car) }
    should("respond to active_record_car=") { assert @wheel.respond_to?(:active_record_car=) }
    should("respond to active_record_car_id") { assert @wheel.respond_to?(:active_record_car_id) }
  end

  context "A class with a has_one :active_record_climate_control_unit association" do
    setup do
      setup_fixtures
      @dashboard = MongoMapperDashboard.new
    end

    should("respond to active_record_climate_control_unit") { assert @dashboard.respond_to?(:active_record_climate_control_unit) }
    should("respond to active_record_climate_control_unit=") { assert @dashboard.respond_to?(:active_record_climate_control_unit=) }
  end

  context "A class with a has_many :active_record_nuts association" do
    setup do
      setup_fixtures
      @wheel = MongoMapperWheel.new
    end

    should("respond to active_record_nuts") { assert @wheel.respond_to?(:active_record_nuts) }
    should("respond to active_record_nuts=") { assert @wheel.respond_to?(:active_record_nuts=) }
    should("respond to active_record_nut_ids") { assert @wheel.respond_to?(:active_record_nut_ids) }
    should("respond to active_record_nut_ids=") { assert @wheel.respond_to?(:active_record_nut_ids=) }
  end

  context "The object returned by a has_many association" do
    setup do
      setup_fixtures
      @wheel = MongoMapperWheel.new
      @nuts = @wheel.active_record_nuts
    end

    should("respond to <<") { assert @nuts.respond_to?(:<<) }
    should("respond to delete") { assert @nuts.respond_to?(:delete) }
    should("respond to clear") { assert @nuts.respond_to?(:clear) }
    should("respond to empty?") { assert @nuts.respond_to?(:empty?) }
    should("respond to size") { assert @nuts.respond_to?(:size) }
  end

end

