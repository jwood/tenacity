require 'test_helper'

class ClassmethodsTest < Test::Unit::TestCase

  context "A class with a belongs_to :mongo_mapper_object association" do
    setup do
      setup_fixtures
      @object = MongoMapperHasOneTarget.new
    end

    should("respond to mongo_mapper_object") { assert @object.respond_to?(:mongo_mapper_object) }
    should("respond to mongo_mapper_object=") { assert @object.respond_to?(:mongo_mapper_object=) }
    should("respond to mongo_mapper_object_id") { assert @object.respond_to?(:mongo_mapper_object_id) }
  end

  context "A class with a has_one :mongo_mapper_has_one_target association" do
    setup do
      setup_fixtures
      @object = MongoMapperObject.new
    end

    should("respond to mongo_mapper_has_one_target") { assert @object.respond_to?(:mongo_mapper_has_one_target) }
    should("respond to mongo_mapper_has_one_target=") { assert @object.respond_to?(:mongo_mapper_has_one_target=) }
  end

  context "A class with a has_many :mongo_mapper_has_many_targets association" do
    setup do
      setup_fixtures
      @object = MongoMapperObject.new
    end

    should("respond to mongo_mapper_has_many_targets") { assert @object.respond_to?(:mongo_mapper_has_many_targets) }
    should("respond to mongo_mapper_has_many_targets=") { assert @object.respond_to?(:mongo_mapper_has_many_targets=) }
    should("respond to mongo_mapper_has_many_target_ids") { assert @object.respond_to?(:mongo_mapper_has_many_target_ids) }
    should("respond to mongo_mapper_has_many_target_ids=") { assert @object.respond_to?(:mongo_mapper_has_many_target_ids=) }
  end

  context "A class including Tenacity with no associations" do
    should "be able to be saved successfully" do
      object = NoAssociations.new(:name => "Daniel")
      assert object.save
    end
  end

  context "The object returned by a has_many association" do
    setup do
      setup_fixtures
      @object = MongoMapperObject.new
      @targets = @object.mongo_mapper_has_many_targets
    end

    should("respond to <<") { assert @targets.respond_to?(:<<) }
    should("respond to delete") { assert @targets.respond_to?(:delete) }
    should("respond to clear") { assert @targets.respond_to?(:clear) }
    should("respond to empty?") { assert @targets.respond_to?(:empty?) }
    should("respond to size") { assert @targets.respond_to?(:size) }
    should("respond to delete_all") { assert @targets.respond_to?(:delete_all) }
    should("respond to destroy_all") { assert @targets.respond_to?(:destroy_all) }
  end

  context "A class including Tenacity" do
    should "be able to override the default object id type" do
      active_record_object = ActiveRecordObjectWithStringId.new
      active_record_object.id = 'abc999'
      active_record_object.save!

      mongo_mapper_object = MongoMapperObject.create
      mongo_mapper_object.active_record_object_with_string_id = active_record_object
      mongo_mapper_object.save

      assert_equal active_record_object, MongoMapperObject._t_find(mongo_mapper_object.id).active_record_object_with_string_id
    end
  end

end

