module Tenacity
  module HasMany #:nodoc:

    private

    def has_many_associates(association_id)
      ids = _t_get_associate_ids(association_id)
      clazz = Kernel.const_get(association_id.to_s.singularize.camelcase.to_sym)
      clazz._t_find_bulk(ids)
    end

    def has_many_associate_ids(association_id)
      _t_get_associate_ids(association_id)
    end

    def set_has_many_associate_ids(association_id, associate_ids)
      clazz = Kernel.const_get(association_id.to_s.singularize.camelcase.to_sym)
      instance_variable_set ivar_name(association_id), clazz._t_find_bulk(associate_ids)
    end

    def save_without_callback
      @perform_save_associates_callback = false
      save
      @perform_save_associates_callback = true
    end

    module ClassMethods #:nodoc:
      def define_has_many_properties(association_id)
        _t_initialize_has_many_association(association_id) if self.respond_to?(:_t_initialize_has_many_association)
      end

      def _t_save_associates(record, association_id)
        return if record.perform_save_associates_callback == false

        _t_clear_old_associations(record, association_id)

        associates = (record.instance_variable_get "@_t_#{association_id.to_s}") || []
        associates.each do |associate|
          associate.send("#{ActiveSupport::Inflector.underscore(record.class.to_s)}_id=", record.id)
          associate.respond_to?(:_t_save_without_callback) ? associate._t_save_without_callback : associate.save
        end

        unless associates.blank?
          associate_ids = associates.map { |associate| associate.id }
          record._t_associate_many(association_id, associate_ids)
          record.respond_to?(:_t_save_without_callback) ? record._t_save_without_callback : record.save
        end
      end

      def _t_clear_old_associations(record, association_id)
        clazz = Kernel.const_get(association_id.to_s.singularize.camelcase.to_sym)
        property_name = "#{ActiveSupport::Inflector.underscore(record.class.to_s)}_id"

        old_associates = clazz._t_find_all_by_associate(property_name, record.id)
        old_associates.each do |old_associate|
          old_associate.send("#{property_name}=", nil)
          old_associate.respond_to?(:_t_save_without_callback) ? old_associate._t_save_without_callback : old_associate.save
        end

        record._t_clear_associates(association_id)
        record.respond_to?(:_t_save_without_callback) ? record._t_save_without_callback : record.save
      end
    end

  end
end

