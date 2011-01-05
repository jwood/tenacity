module Tenacity
  module HasOne #:nodoc:

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

      def _t_stringify_has_one_value(record, association)
        record.send "#{association.foreign_key}=", record.send(association.foreign_key).to_s
      end
    end

  end
end

