require 'test_helper'

class HasOneTest < Test::Unit::TestCase

  for_each_orm_extension_combination do |source, target|
    context "A #{source} class with a has_one association to a #{target} class" do
      setup do
        setup_fixtures_for(source, target)

        @source_class = class_for_extension(source)
        @source = @source_class.create({})
        @target_class = class_for_extension(target, :t_has_one)
        @target = @target_class.create({})

        @foreign_key = foreign_key_for(target, :t_has_one)
        @foreign_key_id = foreign_key_id_for(target, :t_has_one)
      end

      should "be able to set and get the associated object" do
        @source.send("#{@foreign_key}=", @target)
        assert_equal @target, @source_class._t_find(serialize_id(@source)).send(@foreign_key)
      end

      should "return nil if no association is set" do
        assert_nil @source_class._t_find(serialize_id(@source)).send(@foreign_key)
      end

      should "be able to invoke the post delete callback" do
        @source_class._t_delete([serialize_id(@source)])
      end

      should "be able to destroy the associated object when an object is destroyed" do
        Tenacity::Association.any_instance.stubs(:dependent).returns(:destroy, nil)

        @source.send("#{@foreign_key}=", @target)
        assert_equal @target, @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        @source.destroy

        assert_nil @source_class._t_find(serialize_id(@source))
        assert_nil @target_class._t_find(serialize_id(@target))
      end

      should "be able to delete the associated object when an object is destroyed" do
        Tenacity::Association.any_instance.stubs(:dependent).returns(:delete)

        @source.send("#{@foreign_key}=", @target)
        assert_equal @target, @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        @source.destroy

        assert_nil @source_class._t_find(serialize_id(@source))
        assert_nil @target_class._t_find(serialize_id(@target))
      end

      should "be able to nullify the foreign key of the associated object when an object is destroyed" do
        Tenacity::Association.any_instance.stubs(:dependent).returns(:nullify)

        @source.send("#{@foreign_key}=", @target)
        assert_equal @target, @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        @source.destroy

        assert_nil @source_class._t_find(serialize_id(@source))
        assert_not_nil @target_class._t_find(serialize_id(@target))
        assert_nil @target_class._t_find(serialize_id(@target)).send(foreign_key_id_for(target, :t_belongs_to))
      end

      context "with a polymorphic association" do
        setup do
          @foreign_key = "#{target}_has_one_target_testable"
          @polymorphic_type = "#{target}_has_one_target_testable_type"
        end

        should "be able to store an object via its polymorphic interface" do
          @source.send("#{@foreign_key}=", @target)
          @source.save

          reloaded_target = @source_class._t_find(serialize_id(@source)).send(@foreign_key)
          assert_equal @target, reloaded_target
          assert_equal @source_class.to_s, reloaded_target.send(@polymorphic_type)
        end
      end
    end
  end

end
