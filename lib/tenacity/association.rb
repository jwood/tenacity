module Tenacity
  class Association
    attr_reader :type, :name, :source, :class_name, :foreign_key,
                :foreign_keys_property, :join_table, :association_key,
                :association_foreign_key

    def initialize(type, name, source, options={})
      @type = type
      @name = name
      @source = source
      @foreign_key = options[:foreign_key]
      @foreign_keys_property = options[:foreign_keys_property]
      @join_table = options[:join_table]
      @association_key = options[:association_key]
      @association_foreign_key = options[:association_foreign_key]

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

    def join_table
      @join_table || (name.to_s < @source.table_name ? "#{name}_#{@source.table_name}" : "#{@source.table_name}_#{name}")
    end

    def association_key
      @association_key || @source.table_name.singularize + '_id'
    end

    def association_foreign_key
      @association_foreign_key || name.to_s.singularize + '_id'
    end
  end
end
