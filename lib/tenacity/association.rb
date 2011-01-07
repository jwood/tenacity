module Tenacity
  class Association
    attr_reader :type, :name, :source, :class_name

    def initialize(type, name, source, options={})
      @type = type
      @name = name
      @source = source

      if options[:class_name]
        @class_name = options[:class_name]
      else
        @class_name = name.to_s.singularize.camelcase
      end

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
    end

    def associate_class
      @clazz ||= Kernel.const_get(@class_name)
    end

    def foreign_key(clazz=nil)
      @foreign_key || begin
        if @type == :t_belongs_to
          @class_name.underscore + "_id"
        elsif @type == :t_has_one || @type == :t_has_many
          "#{ActiveSupport::Inflector.underscore(clazz)}_id"
        end
      end
    end

    def foreign_keys_property
      @foreign_keys_property || "t_" + ActiveSupport::Inflector.singularize(name) + "_ids"
    end

    def join_table
      if @join_table || @source.respond_to?(:table_name)
        @join_table || (name.to_s < @source.table_name ? "#{name}_#{@source.table_name}" : "#{@source.table_name}_#{name}")
      end
    end

    def association_key
      if @association_key || @source.respond_to?(:table_name)
        @association_key || @source.table_name.singularize + '_id'
      end
    end

    def association_foreign_key
      @association_foreign_key || name.to_s.singularize + '_id'
    end
  end
end
