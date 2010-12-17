module Tenacity
  module ClassMethods

    def t_has_one(association_id, args={})
      define_method(association_id) do |*params|
        get_associate(association_id, params) do
          has_one_associate(association_id)
        end
      end

      define_method("#{association_id}=") do |associate|
        set_associate(association_id, associate) do
          set_has_one_associate(association_id, associate)
        end
      end
    end

    def t_belongs_to(association_id, args={})
      extend(BelongsTo::ClassMethods)

      _t_define_belongs_to_properties(association_id) if self.respond_to?(:_t_define_belongs_to_properties)

      define_method(association_id) do |*params|
        get_associate(association_id, params) do
          belongs_to_associate(association_id)
        end
      end

      define_method("#{association_id}=") do |associate|
        set_associate(association_id, associate) do
          set_belongs_to_associate(association_id, associate)
        end
      end
    end

    def t_has_many(association_id, args={})
      extend(HasMany::ClassMethods)

      attr_accessor "_t_" + association_id.to_s
      attr_accessor :perform_save_associates_callback

      _t_define_has_many_properties(association_id) if self.respond_to?(:_t_define_has_many_properties)

      define_method(association_id) do
        has_many_associates(association_id)
      end

      define_method("#{association_id}=") do |associates|
        set_has_many_associates(association_id, associates)
      end

      define_method("#{ActiveSupport::Inflector.singularize(association_id.to_s)}_ids") do
        has_many_associate_ids(association_id)
      end

      define_method("#{ActiveSupport::Inflector.singularize(association_id.to_s)}_ids=") do |associate_ids|
        set_has_many_associate_ids(association_id, associate_ids)
      end

      private

      define_method(:_t_save_without_callback) do
        save_without_callback
      end
    end

  end
end

