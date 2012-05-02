module Tenacity
  module Associations
    module HasOne #:nodoc:

      def _t_cleanup_has_one_association(association)
        associate = has_one_associate(association)
        unless associate.nil?
          if association.dependent == :destroy
            delete_or_destroy_has_one_associate(association, associate)
          elsif association.dependent == :delete
            delete_or_destroy_has_one_associate(association, associate, false)
          elsif association.dependent == :nullify
            nullify_foreign_key_for_has_one_associate(association, associate)
          elsif association.foreign_key_constraints_enabled?
            raise ObjectIdInUseError.new("Unable to delete #{self.class} with id of #{self.id} because its id is being referenced by an instance of #{associate.class}(id: #{associate.id})!")
          end
        end
      end

      private

      def has_one_associate(association)
        clazz = association.associate_class
        clazz._t_find_first_by_associate(association.foreign_key(self.class), _t_serialize(self.id, association),association)
      end

      def set_has_one_associate(association, associate)
        associate.send "#{association.foreign_key(self.class)}=", _t_serialize(self.id, association)
        associate.send "#{association.polymorphic_type}=", self.class.to_s if association.polymorphic?
        associate._t_save_if_dirty unless association.autosave == false
        associate
      end

      def delete_or_destroy_has_one_associate(association, associate, run_callbacks=true)
        association.associate_class._t_delete(_t_serialize(associate.id), run_callbacks)
      end

      def nullify_foreign_key_for_has_one_associate(association, associate)
        associate.send "#{association.foreign_key(self.class)}=", nil
        associate._t_save_if_dirty
      end

      module ClassMethods #:nodoc:
        def initialize_has_one_association(association)
          _t_initialize_has_one_association(association) if respond_to?(:_t_initialize_has_one_association)
        end
      end

    end
  end
end

