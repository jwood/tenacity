module Tenacity

  # The Associaiton class represents a Tenacity association.  Using this class,
  # you can retrieve all sorts of information about the association, including
  # it name, type, source, target class, etc.
  class Association

    # Type type of the association (<tt>:t_has_one</tt>, <tt>:t_has_many</tt>, or <tt>:t_belongs_to</tt>)
    attr_reader :type

    # The class defining the association
    attr_reader :source

    # The name of the associated class
    attr_reader :class_name

    # What happens to the associated object when the object is deleted
    attr_reader :dependent

    # Are the associated objects read only?
    attr_reader :readonly

    # The limit on the number of results to be returned.
    attr_reader :limit

    # The offset from where the results should be fetched.
    attr_reader :offset

    # Should the associated object be saved when the parent object is saved?
    attr_reader :autosave

    # The interface this association is reffered to as
    attr_reader :as

    # Is this association a polymorphic association?
    attr_reader :polymorphic

    # Should this association disable foreign key like constraints
    attr_reader :disable_foreign_key_constraints
    
    # Filter records based on a defined condition. At this time only activerecord supports this
    attr_reader :conditions

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
      @dependent = options[:dependent]
      @readonly = options[:readonly]
      @limit = options[:limit]
      @offset = options[:offset]
      @autosave = options[:autosave]
      @polymorphic = options[:polymorphic]
      @as = options[:as]
      @disable_foreign_key_constraints = options[:disable_foreign_key_constraints]
      @conditions = options[:conditions]
    end

    # The name of the association
    def name
      @as.nil? ? @name : @as
    end

    # Get the associated class
    def associate_class(object=nil)
      if @type == :t_belongs_to && polymorphic?
        qualified_const_get(object.send(polymorphic_type))
      else
        @clazz ||= qualified_const_get(@class_name)
      end
    end

    # Get the foreign key used by this association. <tt>t_has_one</tt> and
    # <tt>t_has_many</tt> associations need the class of the associated object
    # to be specified in order to properly determine the name of the foreign key.
    def foreign_key(clazz=nil)
      @foreign_key || begin
        if @type == :t_belongs_to
          belongs_to_foreign_key
        elsif @type == :t_has_one || @type == :t_has_many
          has_x_foreign_key(clazz)
        end
      end
    end

    # Are the associated objects read only?
    def readonly?
      @readonly == true
    end

    # Is this association a polymorphic association?
    def polymorphic?
      @polymorphic == true || !@as.nil?
    end

    # The name of the property that stores the polymorphic type (for polymorphic associations)
    def polymorphic_type
      (name.to_s + "_type").to_sym
    end

    # Are foreign key constraints enabled for this association?
    def foreign_key_constraints_enabled?
      @disable_foreign_key_constraints != true
    end

    private

    # Shamelessly copied from http://redcorundum.blogspot.com/2006/05/kernelqualifiedconstget.html
    def qualified_const_get(clazz)
      path = clazz.to_s.split('::')
      from_root = path[0].empty?

      if from_root
        from_root = []
        path = path[1..-1]
      else
        start_ns = ((Class === self) || (Module === self)) ? self : self.class
        from_root = start_ns.to_s.split('::')
      end

      until from_root.empty?
        begin
          return (from_root + path).inject(Object) { |ns,name| ns.const_get(name) }
        rescue NameError
          from_root.delete_at(-1)
        end
      end

      path.inject(Object) { |ns,name| ns.const_get(name) }
    end

    def unqualified_class_name(clazz)
      clazz.to_s.split('::').last
    end

    def belongs_to_foreign_key
      if polymorphic?
        (name.to_s + "_id").to_sym
      else
        unqualified_class_name(@class_name).underscore + "_id"
      end
    end

    def has_x_foreign_key(clazz)
      raise "The class of the associate must be provided in order to determine the name of the foreign key" if clazz.nil?
      if polymorphic?
        (@as.to_s + "_id").to_sym
      else
        "#{ActiveSupport::Inflector.underscore(unqualified_class_name(clazz))}_id"
      end
    end
  end
end
