module Tenacity
  module Associations
    module BelongsTo #:nodoc:

      def _t_cleanup_belongs_to_association(association)
        associate_id = self.send(association.foreign_key)
        if associate_id != nil && associate_id.to_s.strip != ''
          if association.dependent == :destroy
            association.associate_class._t_delete(associate_id)
          elsif association.dependent == :delete
            association.associate_class._t_delete(associate_id, false)
          end
        end
      end

      private

      def belongs_to_associate(association)
        associate_id = self.send(association.foreign_key)
        clazz = association.associate_class
        associate = clazz._t_find(associate_id)
        associate
      end

      def set_belongs_to_associate(association, associate)
        self.send "#{association.foreign_key}=", _t_serialize(associate.id)
        associate
      end

      module ClassMethods #:nodoc:
        def initialize_belongs_to_association(association)
          _t_initialize_belongs_to_association(association) if self.respond_to?(:_t_initialize_belongs_to_association)
        end
      end

    end
  end
end

