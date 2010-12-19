module Tenacity
  module BelongsTo #:nodoc:

    private

    def belongs_to_associate(association_id)
      associate_id = self.send("#{association_id}_id")
      clazz = associate_class(association_id)
      clazz._t_find(associate_id)
    end

    def set_belongs_to_associate(association_id, associate)
      self.send "#{association_id}_id=", associate.id.to_s
    end

    module ClassMethods #:nodoc:
      def initialize_belongs_to_association(association_id)
        _t_initialize_belongs_to_association(association_id) if self.respond_to?(:_t_initialize_belongs_to_association)
      end

      def _t_stringify_belongs_to_value(record, association_id)
        record.send "#{association_id}_id=", record.send("#{association_id}_id").to_s
      end
    end

  end
end

