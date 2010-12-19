module Tenacity
  module HasOne #:nodoc:

    private

    def has_one_associate(association_id)
      clazz = associate_class(association_id)
      clazz._t_find_first_by_associate(property_name, self.id.to_s)
    end

    def set_has_one_associate(association_id, associate)
      associate.send "#{property_name}=", self.id.to_s
      associate.save
    end

    def property_name
      "#{ActiveSupport::Inflector.underscore(self.class.to_s)}_id"
    end

    module ClassMethods #:nodoc:
      def initialize_has_one_association(association_id)
        begin
          require association_id.to_s
        rescue e
          puts "#{association_id.to_s} does not appear to be in the load path"
          raise
        end

        clazz = associate_class(association_id)
        clazz._t_initialize_has_one_association(ActiveSupport::Inflector.underscore(self.to_s)) if clazz.respond_to?(:_t_initialize_has_one_association)
      end

      def _t_stringify_has_one_value(record, association_id)
        record.send "#{association_id}_id=", record.send("#{association_id}_id").to_s
      end
    end

  end
end

