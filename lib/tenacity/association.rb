module Tenacity
  class Association
    attr_reader :name, :class_name

    def initialize(name, options={})
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

    def foreign_key
      @class_name.underscore + "_id"
    end
  end
end
