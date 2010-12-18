module Tenacity
  module HasOne #:nodoc:

    private

    def has_one_associate(association_id)
      clazz = Kernel.const_get(association_id.to_s.camelcase.to_sym)
      clazz._t_find_first_by_associate("#{ActiveSupport::Inflector.underscore(self.class.to_s)}_id", self.id.to_s)
    end

    def set_has_one_associate(association_id, associate)
      associate.send "#{ActiveSupport::Inflector.underscore(self.class.to_s)}_id=", self.id.to_s
      associate.save
    end

    module ClassMethods #:nodoc:
      def define_has_one_properties(association_id)
        require association_id.to_s
        clazz = Kernel.const_get(association_id.to_s.camelcase.to_sym)
        clazz._t_define_has_one_properties(ActiveSupport::Inflector.underscore(self.to_s)) if clazz.respond_to?(:_t_define_has_one_properties)
      end

      def _t_stringify_has_one_value(record, association_id)
        record.send "#{association_id}_id=".to_sym, record.send("#{association_id}_id").to_s
      end
    end

  end
end

