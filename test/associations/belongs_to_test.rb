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
        @target.send("#{@foreign_key_id}=", @source.id.to_s)
        @target.save
        assert_equal @source.id.to_s, @target_class._t_find(@target.id.to_s).send(@foreign_key_id)
      end

      should "be able to load the associated object" do
        @target.send("#{@foreign_key}=", @source)
        @target.save
        assert_equal @source.id.to_s, @target_class._t_find(@target.id.to_s).send(@foreign_key_id)
        assert_equal @source, @target_class._t_find(@target.id.to_s).send(@foreign_key)
      end

      should "be be able to load the associated object if all we have is the id" do
        @target.send("#{@foreign_key_id}=", @source.id.to_s)
        @target.save
        assert_equal @source, @target_class._t_find(@target.id.to_s).send(@foreign_key)
      end

      should "return nil if no association is set" do
        assert_nil @target_class._t_find(@target.id.to_s).send(@foreign_key)
      end

      should "be able to invoke the post delete callback" do
        @target.send("#{@foreign_key}=", @source)
        @target.save
        @target_class._t_delete([@target.id])
      end
    end
  end

end
