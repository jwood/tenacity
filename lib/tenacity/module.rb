require 'active_support/inflector'

module Tenacity
  autoload :BelongsTo, 'tenacity/belongs_to'

  def self.included(model)
    raise "Tenacity does not support the ORM used by #{model}" unless model.respond_to?(:_t_find)

    include BelongsTo
    model.extend(ClassMethods)
  end 

  module ClassMethods
    def t_belongs_to(association_id, args={})
      _t_define_belongs_to_properties(association_id) if self.respond_to?(:_t_define_belongs_to_properties)

      define_method(association_id) do
        belongs_to_associate(association_id)
      end

      define_method("#{association_id}=") do |associate|
        set_belongs_to_associate(association_id, associate)
      end
    end

    def t_has_many(association_id, args={})
      collection_name = "_t_" + association_id.to_s
      attr_accessor collection_name
      attr_accessor :perform_save_associates_callback

      _t_define_has_many_properties(association_id) if self.respond_to?(:_t_define_has_many_properties)

      define_method(association_id) do
        clazz = Kernel.const_get(association_id.to_s.singularize.camelcase.to_sym)
        value = instance_variable_get "@#{collection_name}"
        if value.nil?
          ids = _t_get_associate_ids(association_id)
          value = clazz._t_find_bulk(ids)
          instance_variable_set "@#{collection_name}", value
        end
        value
      end

      define_method("#{association_id}=") do |associates|
        instance_variable_set "@#{collection_name}", associates
      end

      define_method("#{ActiveSupport::Inflector.singularize(association_id.to_s)}_ids") do
        _t_get_associate_ids(association_id)
      end

      define_method("#{ActiveSupport::Inflector.singularize(association_id.to_s)}_ids=") do |associate_ids|
        clazz = Kernel.const_get(association_id.to_s.singularize.camelcase.to_sym)
        instance_variable_set "@#{collection_name}", clazz._t_find_bulk(associate_ids)
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

      define_method(:_t_save_without_callback) do
        @perform_save_associates_callback = false
        save
        @perform_save_associates_callback = true
      end
    end
  end
end
