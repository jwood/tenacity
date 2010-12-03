require 'active_support/inflector'

module Tenacity
  def self.included(model)
    raise "Tenacity does not support the ORM used by #{model}" unless model.respond_to?(:_t_find)
    model.extend(ClassMethods)
  end 

  module ClassMethods
    def t_belongs_to(association_id, args={})
      define_method(association_id) do
        associate_id = self.send("#{association_id}_id")
        clazz = Kernel.const_get(association_id.to_s.camelcase.to_sym)
        clazz.send(:_t_find, associate_id)
      end

      define_method("#{association_id}=") do |associate|
        self.send "#{association_id}_id=".to_sym, associate.id
      end
    end

    def t_has_many(association_id, args={})
      define_method(association_id) do
        []
      end

      define_method("#{association_id}=") do
      end

      define_method("#{ActiveSupport::Inflector.singularize(association_id.to_s)}_ids") do
      end

      define_method("#{ActiveSupport::Inflector.singularize(association_id.to_s)}_ids=") do
      end
    end
  end

end
