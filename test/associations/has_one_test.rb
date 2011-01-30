require 'test_helper'

class HasOneTest < Test::Unit::TestCase

  for_each_orm_extension_combination do |source, target|
    context "A #{source} class with a has_one association to a #{target} class" do
      setup do
        setup_fixtures_for(source, target)

        @source_class = class_for_extension(source)
        @source = @source_class.create({})
        @target_class = class_for_extension(target, :has_one)
        @target = @target_class.create({})

        @foreign_key = foreign_key_for(target, :has_one)
        @foreign_key_id = foreign_key_id_for(target, :has_one)
      end

      should "be able to set and get the associated object" do
        @source.send("#{@foreign_key}=", @target)
        assert_equal @target, @source_class._t_find(@source.id.to_s).send(@foreign_key)
      end

      should "return nil if no association is set" do
        assert_nil @source_class._t_find(@source.id.to_s).send(@foreign_key)
      end

      should "be able to invoke the post delete callback" do
        @source.send("#{@foreign_key}=", @target)
        @source_class._t_delete([@source.id])
      end
    end
  end

end
