module Tenacity
  class Association
    attr_reader :type, :name, :class_name, :foreign_key, :foreign_keys_property

    def initialize(type, name, options={})
      @type = type
      @name = name
      @foreign_key = options[:foreign_key]
      @foreign_keys_property = options[:foreign_keys_property]

      if @foreign_keys_property
        if @foreign_keys_property.to_s == ActiveSupport::Inflector.singularize(name) + "_ids"
          raise "#{ActiveSupport::Inflector.singularize(name) + "_ids"} is an invalid foreign keys property name"
        end
      end

      if options[:class_name]
        @class_name = options[:class_name]
      else
        @class_name = name.to_s.singularize.camelcase
      end
    end

    def associate_class
      @clazz ||= Kernel.const_get(@class_name)
    end

    def foreign_key(clazz=nil)
      if @type == :t_belongs_to
        @foreign_key || @class_name.underscore + "_id"
      elsif @type == :t_has_one
        @foreign_key || "#{ActiveSupport::Inflector.underscore(clazz)}_id"
      elsif @type == :t_has_many
        @foreign_key || "#{ActiveSupport::Inflector.underscore(clazz)}_id"
      end
    end

    def foreign_keys_property
      @foreign_keys_property || "t_" + ActiveSupport::Inflector.singularize(name) + "_ids"
    end
  end
end
