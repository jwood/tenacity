require 'active_support/inflector'

module Tenacity
  def self.included(model)
    raise "Tenacity does not support the ORM used by #{model}" unless model.respond_to?(:_t_find)
    model.extend(ClassMethods)
  end 

  module ClassMethods
    def t_belongs_to(association_id, args={})
      _t_define_belongs_to_properties(association_id) if self.respond_to?(:_t_define_belongs_to_properties)

      define_method(association_id) do
        associate_id = self.send("#{association_id}_id")
        clazz = Kernel.const_get(association_id.to_s.camelcase.to_sym)
        clazz._t_find(associate_id)
      end

      define_method("#{association_id}=") do |associate|
        self.send "#{association_id}_id=".to_sym, associate.id
      end
    end

    def t_has_many(association_id, args={})
      collection_name = "_t_" + association_id.to_s
      attr_accessor collection_name

      _t_define_has_many_properties(association_id) if self.respond_to?(:_t_define_has_many_properties)

      define_method(association_id) do
        clazz = Kernel.const_get(association_id.to_s.singularize.camelcase.to_sym)
        value = instance_variable_get "@#{collection_name}"
        if value.nil?
          value = clazz._t_find_all_by_associate("#{ActiveSupport::Inflector.underscore(self.class.to_s)}_id", self.id)
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

      def save_associates(record, association_id)
        associates = (record.instance_variable_get "@_t_#{association_id.to_s}") || []
        associates.each do |associate|
          associate.send("#{ActiveSupport::Inflector.underscore(record.class.to_s)}_id=", record.id)
          associate.save
        end

        unless associates.blank?
          associate_ids = associates.map { |associate| associate.id }
          record._t_associate_many(association_id, associate_ids)
        end
      end
    end
  end
end
