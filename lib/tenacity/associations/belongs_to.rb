module Tenacity
  module Associations
    module BelongsTo #:nodoc:

      def _t_cleanup_belongs_to_association(association)
        associate_id = self.send(association.foreign_key)
        if associate_id != nil && associate_id.to_s.strip != ''
          if association.dependent == :destroy
            delete_or_destroy_belongs_to_associate(association, associate_id)
          elsif association.dependent == :delete
            delete_or_destroy_belongs_to_associate(association, associate_id, false)
          end
        end
      end

      private

      def belongs_to_associate(association)
        associate_id = self.send(association.foreign_key)
        clazz = association.associate_class(self)
        clazz._t_find(associate_id,association)
      end

      def set_belongs_to_associate(association, associate)
        self.send "#{association.foreign_key}=", _t_serialize(associate.id)
        self.send "#{association.polymorphic_type}=", associate.class.to_s if association.polymorphic?
        associate
      end

      def delete_or_destroy_belongs_to_associate(association, associate_id, run_callbacks=true)
        association.associate_class._t_delete(associate_id, run_callbacks)
      end

      module ClassMethods #:nodoc:
        def initialize_belongs_to_association(association)
          _t_initialize_belongs_to_association(association) if self.respond_to?(:_t_initialize_belongs_to_association)
        end
      end

    end
  end
end

