module Tenacity
  module Associations
    module HasOne #:nodoc:

      def _t_cleanup_has_one_association(association)
        associate = has_one_associate(association)
        unless associate.nil?
          if association.dependent == :destroy
            association.associate_class._t_delete([_t_serialize(associate.id)])
          elsif association.dependent == :delete
            association.associate_class._t_delete([_t_serialize(associate.id)], false)
          elsif association.dependent == :nullify
            associate.send "#{association.foreign_key(self.class)}=", nil
            associate.save
          elsif association.foreign_key_constraints_enabled?
            raise ObjectIdInUseError.new("Unable to delete #{self.class} with id of #{self.id} because its id is being referenced by an instance of #{associate.class}(id: #{associate.id})!")
          end
        end
      end

      private

      def has_one_associate(association)
        clazz = association.associate_class
        clazz._t_find_first_by_associate(association.foreign_key(self.class), _t_serialize(self.id, association))
      end

      def set_has_one_associate(association, associate)
        associate.send "#{association.foreign_key(self.class)}=", _t_serialize(self.id, association)
        associate.send "#{association.polymorphic_type}=", self.class.to_s if association.polymorphic?
        associate.save unless association.autosave == false
        associate
      end

      module ClassMethods #:nodoc:
        def initialize_has_one_association(association)
          _t_initialize_has_one_association(association) if respond_to?(:_t_initialize_has_one_association)
        end
      end

    end
  end
end

