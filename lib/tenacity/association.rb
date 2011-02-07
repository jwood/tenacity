module Tenacity

  # The Associaiton class represents a Tenacity association.  Using this class,
  # you can retrieve all sorts of information about the association, including
  # it name, type, source, target class, etc.
  class Association

    # Type type of the association (<tt>:t_has_one</tt>, <tt>:t_has_many</tt>, or <tt>:t_belongs_to</tt>)
    attr_reader :type

    # The name of the association
    attr_reader :name

    # The class defining the association
    attr_reader :source

    # The name of the associated class
    attr_reader :class_name

    # What happens to the associated object when the object is deleted
    attr_reader :dependent

    # Are the associated objects read only?
    attr_reader :readonly

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
      @dependent = options[:dependent]
      @readonly = options[:readonly]

      if @foreign_keys_property
        if @foreign_keys_property.to_s == ActiveSupport::Inflector.singularize(name) + "_ids"
          raise "#{ActiveSupport::Inflector.singularize(name) + "_ids"} is an invalid foreign keys property name"
        end
      end
    end

    # Get the associated class
    def associate_class
      @clazz ||= Kernel.const_get(@class_name)
    end

    # Get the foreign key used by this association. <tt>t_has_one</tt> and
    # <tt>t_has_many</tt> associations need the class of the associated object
    # to be specified in order to properly determine the name of the foreign key.
    def foreign_key(clazz=nil)
      @foreign_key || begin
        if @type == :t_belongs_to
          @class_name.underscore + "_id"
        elsif @type == :t_has_one || @type == :t_has_many
          raise "The class of the associate must be provided in order to determine the name of the foreign key" if clazz.nil?
          "#{ActiveSupport::Inflector.underscore(clazz)}_id"
        end
      end
    end

    # Get the property name used to store the foreign key
    def foreign_keys_property
      @foreign_keys_property || "t_" + ActiveSupport::Inflector.singularize(name) + "_ids"
    end

    # Get the name of the join table used by this association
    def join_table
      table_name = fetch_table_name
      @join_table || (name.to_s < table_name ? "#{name}_#{table_name}" : "#{table_name}_#{name}")
    end

    # Get the name of the column in the join table that represents this object
    def association_key
      table_name = fetch_table_name
      @association_key || table_name.singularize + '_id'
    end

    # Get the name of the column in the join table that represents the associated object
    def association_foreign_key
      @association_foreign_key || name.to_s.singularize + '_id'
    end

    # Are the associated objects read only?
    def readonly?
      @readonly == true
    end

    private

    def fetch_table_name
      if @source.respond_to?(:table_name)
        @source.table_name.to_s
      else
        "#{ActiveSupport::Inflector.underscore(@source)}s"
      end
    end
  end
end
