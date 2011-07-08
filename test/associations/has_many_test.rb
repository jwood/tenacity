require 'test_helper'

class HasManyTest < Test::Unit::TestCase

  for_each_orm_extension_combination do |source, target|
    context "A #{source} class with a has_many association to a #{target} class" do
      setup do
        setup_fixtures_for(source, target)

        @source_class = class_for_extension(source)
        @source = @source_class.create({})
        @target_class = class_for_extension(target, :t_has_many)
        @target_1 = @target_class.create({})
        @target_2 = @target_class.create({})
        @target_3 = @target_class.create({})

        @foreign_key = foreign_key_for(target, :t_has_many)
        @foreign_key_id = foreign_key_id_for(target, :t_has_many)
      end

      should "be able to set the associated objects by their ids" do
        @source.send("#{@foreign_key_id}=", [@target_1.id, @target_2.id, @target_3.id])
        @source.save
        [@target_1, @target_2, @target_3].each { |t| t._t_reload }
        assert_set_equal [@target_1, @target_2, @target_3], @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        assert_set_equal [serialize_id(@target_1), serialize_id(@target_2), serialize_id(@target_3)], @source_class._t_find(serialize_id(@source)).send(@foreign_key_id)
      end

      context "that works with associated objects" do
        setup do
          @source.send("#{@foreign_key}=", [@target_1, @target_2, @target_3])
          @source.save
        end

        should "be able to set the associated objects" do
          [@target_1, @target_2, @target_3].each { |t| t._t_reload }
          assert_set_equal [@target_1, @target_2, @target_3], @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        end

        should "be able to add an associated object using the << operator" do
          target_4 = @target_class.create({})
          @source.send(@foreign_key) << target_4
          @source.save
          [@target_1, @target_2, @target_3, target_4].each { |t| t._t_reload }
          assert_set_equal [@target_1, @target_2, @target_3, target_4], @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        end

        should "be able to add an associated object using the push method" do
          target_4 = @target_class.create({})
          target_5 = @target_class.create({})
          @source.send(@foreign_key).push(target_4, target_5)
          @source.save
          [@target_1, @target_2, @target_3, target_4, target_5].each { |t| t._t_reload }
          assert_set_equal [@target_1, @target_2, @target_3, target_4, target_5], @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        end

        should "be able to add an associated object using the concat method" do
          target_4 = @target_class.create({})
          target_5 = @target_class.create({})
          @source.send(@foreign_key).concat([target_4, target_5])
          @source.save
          [@target_1, @target_2, @target_3, target_4, target_5].each { |t| t._t_reload }
          assert_set_equal [@target_1, @target_2, @target_3, target_4, target_5], @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        end

        should "be able to remove an associated object using the delete method" do
          @source.send(@foreign_key).delete(@target_3)
          @source.save
          [@target_1, @target_2].each { |t| t._t_reload }
          assert_set_equal [@target_1, @target_2], @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        end

        should "be able to clear all associated objects using the clear method" do
          @source.send(@foreign_key).clear
          @source.save
          assert_set_equal [], @source_class._t_find(serialize_id(@source)).send(@foreign_key)
        end

        should "return an empty array if the association is not set" do
          s = @source_class.create({})
          assert_set_equal [], @source_class._t_find(serialize_id(s)).send(@foreign_key)
        end

        should "be able to destroy the associated object when an object is destroyed" do
          Tenacity::Association.any_instance.stubs(:dependent).returns(:destroy, nil)
          @source.destroy

          assert_nil @source_class._t_find(serialize_id(@source))
          assert_nil @target_class._t_find(serialize_id(@target_1))
          assert_nil @target_class._t_find(serialize_id(@target_2))
          assert_nil @target_class._t_find(serialize_id(@target_3))
        end

        should "be able to delete the associated object when an object is destroyed" do
          Tenacity::Association.any_instance.stubs(:dependent).returns(:delete_all)
          @source.destroy

          assert_nil @source_class._t_find(serialize_id(@source))
          assert_nil @target_class._t_find(serialize_id(@target_1))
          assert_nil @target_class._t_find(serialize_id(@target_2))
          assert_nil @target_class._t_find(serialize_id(@target_3))
        end

        should "be able to nullify the foreign key of the associated object when an object is destroyed" do
          Tenacity::Association.any_instance.stubs(:dependent).returns(:nullify)
          @source.destroy

          assert_nil @source_class._t_find(serialize_id(@source))
          assert_not_nil @target_class._t_find(serialize_id(@target_1))
          assert_not_nil @target_class._t_find(serialize_id(@target_2))
          assert_not_nil @target_class._t_find(serialize_id(@target_3))
          assert_nil @target_class._t_find(serialize_id(@target_1)).send(foreign_key_id_for(target, :t_belongs_to))
          assert_nil @target_class._t_find(serialize_id(@target_2)).send(foreign_key_id_for(target, :t_belongs_to))
          assert_nil @target_class._t_find(serialize_id(@target_3)).send(foreign_key_id_for(target, :t_belongs_to))
        end
      end

      context "with polymorphic associations" do
        setup do
          @foreign_key = "#{target}_has_many_target_testable"
          @polymorphic_type = "#{target}_has_many_target_testable_type"
        end

        should "be able to store an object via its polymorphic interface" do
          @source.send("#{@foreign_key}=", [@target_1, @target_2, @target_3])
          @source.save

          [@target_1, @target_2, @target_3].each { |t| t._t_reload }
          assert_set_equal [@target_1, @target_2, @target_3], @source_class._t_find(serialize_id(@source)).send(@foreign_key)
          [@target_1, @target_2, @target_3].each { |t| assert_equal @source_class.to_s, t.send(@polymorphic_type) }
        end
      end
    end
  end

end
