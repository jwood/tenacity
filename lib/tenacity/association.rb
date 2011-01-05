module Tenacity
  class Association
    attr_reader :association_id, :class_name

    def initialize(association_id, options={})
      @association_id = association_id

      if options[:class_name]
        @class_name = options[:class_name]
      else
        @class_name = association_id.to_s.singularize.camelcase
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
