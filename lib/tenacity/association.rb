module Tenacity
  class Association
    attr_reader :type, :name, :class_name

    def initialize(type, name, options={})
      @type = type
      @name = name

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
        @class_name.underscore + "_id"
      elsif @type == :t_has_one
        "#{ActiveSupport::Inflector.underscore(clazz)}_id"
      end
    end
  end
end
