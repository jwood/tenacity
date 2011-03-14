require 'test_helper'

class BelongsToTest < Test::Unit::TestCase

  for_each_orm_extension_combination do |source, target|
    context "A #{source} class with a belongs_to association to a #{target} class" do
      setup do
        setup_fixtures_for(source, target)

        @source_class = class_for_extension(source)
        @source = @source_class.create({})
        @target_class = class_for_extension(target, :belongs_to)
        @target = @target_class.create({})

        @foreign_key = foreign_key_for(source, :belongs_to)
        @foreign_key_id = foreign_key_id_for(source, :belongs_to)
      end

      should "be able to fetch the id of the associated object" do
        @target.send("#{@foreign_key_id}=", serialize_id(@source))
        @target.save
        assert_equal serialize_id(@source), @target_class._t_find(serialize_id(@target)).send(@foreign_key_id)
      end

      should "be able to load the associated object" do
        @target.send("#{@foreign_key}=", @source)
        @target.save
        assert_equal serialize_id(@source), @target_class._t_find(serialize_id(@target)).send(@foreign_key_id)
        assert_equal @source, @target_class._t_find(serialize_id(@target)).send(@foreign_key)
      end

      should "be be able to load the associated object if all we have is the id" do
        @target.send("#{@foreign_key_id}=", serialize_id(@source))
        @target.save
        assert_equal @source, @target_class._t_find(serialize_id(@target)).send(@foreign_key)
      end

      should "return nil if no association is set" do
        assert_nil @target_class._t_find(serialize_id(@target)).send(@foreign_key)
      end

      should "be able to destroy the associated object when the source object is destroyed" do
        Tenacity::Association.any_instance.stubs(:dependent).returns(:destroy)
        @target.send("#{@foreign_key}=", @source)
        @target.save
        @target_class._t_delete([serialize_id(@target)])
        assert_nil @source_class._t_find(serialize_id(@source))
        assert_nil @target_class._t_find(serialize_id(@target))
      end

      should "be able to delete the associated object when the source object is destroyed" do
        Tenacity::Association.any_instance.stubs(:dependent).returns(:delete)
        @target.send("#{@foreign_key}=", @source)
        @target.save
        @target_class._t_delete([serialize_id(@target)])
        assert_nil @source_class._t_find(serialize_id(@source))
        assert_nil @target_class._t_find(serialize_id(@target))
      end
    end
  end

end
