module Tenacity
  module Associations
    module HasOne #:nodoc:

      def _t_cleanup_has_one_association(association)
        associate = has_one_associate(association)
        unless associate.nil?
          if association.dependent == :destroy
            association.associate_class._t_delete([associate.id.to_s])
          elsif association.dependent == :delete
            association.associate_class._t_delete([associate.id.to_s], false)
          elsif association.dependent == :nullify
            associate.send "#{association.foreign_key(self.class)}=", nil
            associate.save
          end
        end
      end

      private

      def has_one_associate(association)
        clazz = association.associate_class
        clazz._t_find_first_by_associate(association.foreign_key(self.class), self.id.to_s)
      end

      def set_has_one_associate(association, associate)
        associate.send "#{association.foreign_key(self.class)}=", self.id.to_s
        associate.save
      end

      module ClassMethods #:nodoc:
        def initialize_has_one_association(association)
          _t_initialize_has_one_association(association) if respond_to?(:_t_initialize_has_one_association)
        end
      end

    end
  end
end

