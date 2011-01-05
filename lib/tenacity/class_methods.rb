module Tenacity
  # Associations are a set of macro-like class methods for tying objects together through
  # their ids. They express relationships like "Project has one Project Manager"
  # or "Project belongs to a Portfolio". Each macro adds a number of methods to the
  # class which are specialized according to the collection or association symbol and the
  # options hash. It works much the same way as Ruby's own <tt>attr*</tt>
  # methods.
  #
  #   class Project
  #     include Tenacity
  #
  #     t_belongs_to    :portfolio
  #     t_has_one       :project_manager
  #     t_has_many      :milestones
  #   end
  #
  # The project class now has the following methods (and more) to ease the traversal and
  # manipulation of its relationships:
  # * <tt>Project#portfolio, Project#portfolio=(portfolio), Project#portfolio.nil?</tt>
  # * <tt>Project#project_manager, Project#project_manager=(project_manager), Project#project_manager.nil?,</tt>
  # * <tt>Project#milestones.empty?, Project#milestones.size, Project#milestones, Project#milestones<<(milestone), Project#milestones.delete(milestone)</tt>
  #
  # == Cardinality and associations
  #
  # Tenacity associations can be used to describe one-to-one and one-to-many
  # relationships between models. Each model uses an association to describe its role in
  # the relation. The +t_belongs_to+ association is always used in the model that has
  # the foreign key.
  #
  # === One-to-one
  #
  # Use +t_has_one+ in the base, and +t_belongs_to+ in the associated model.
  #
  #   class Employee < ActiveRecord::Base
  #     include Tenacity
  #     t_has_one :office
  #   end
  #
  #   class Office
  #     include MongoMapper::Document
  #     include Tenacity
  #     t_belongs_to :employee     # foreign key - employee_id
  #   end
  #
  # === One-to-many
  #
  # Use +t_has_many+ in the base, and +t_belongs_to+ in the associated model.
  #
  #   class Manager < ActiveRecord::Base
  #     include Tenacity
  #     t_has_many :employees
  #   end
  #
  #   class Employee
  #     include MongoMapper::Document
  #     include Tenacity
  #     t_belongs_to :manager     # foreign key - manager_id
  #   end
  #
  # == Caching
  #
  # All of the methods are built on a simple caching principle that will keep the result
  # of the last query around unless specifically instructed not to. The cache is even
  # shared across methods to make it even cheaper to use the macro-added methods without
  # worrying too much about performance at the first go.
  #
  #   project.milestones             # fetches milestones from the database
  #   project.milestones.size        # uses the milestone cache
  #   project.milestones.empty?      # uses the milestone cache
  #   project.milestones(true).size  # fetches milestones from the database
  #   project.milestones             # uses the milestone cache
  #
  module ClassMethods

    # Specifies a one-to-one association with another class. This method should only be used
    # if the other class contains the foreign key. If the current class contains the foreign key,
    # then you should use +t_belongs_to+ instead.
    #
    # The following methods for retrieval and query of a single associated object will be added:
    #
    # [association(force_reload = false)]
    #   Returns the associated object. +nil+ is returned if none is found.
    # [association=(associate)]
    #   Assigns the associate object, extracts the primary key, sets it as the foreign key,
    #   and saves the associate object.
    #
    # (+association+ is replaced with the symbol passed as the first argument, so
    # <tt>t_has_one :manager</tt> would add among others <tt>manager.nil?</tt>.)
    #
    # === Example
    #
    # An Account class declares <tt>t_has_one :beneficiary</tt>, which will add:
    # * <tt>Account#beneficiary</tt> (similar to <tt>Beneficiary.find(:first, :conditions => "account_id = #{id}")</tt>)
    # * <tt>Account#beneficiary=(beneficiary)</tt> (similar to <tt>beneficiary.account_id = account.id; beneficiary.save</tt>)
    #
    # === Supported options
    # [:class_name]
    #   Specify the class name of the association. Use it only if that name can't be inferred
    #   from the association name. So <tt>t_has_one :manager</tt> will by default be linked to the Manager class, but
    #   if the real class name is Person, you'll have to specify it with this option.
    #
    # Option examples:
    #   t_has_one :project_manager, :class_name => "Person"
    #
    def t_has_one(association_id, options={})
      extend(HasOne::ClassMethods)
      association = Association.new(association_id, options)
      initialize_has_one_association(association)

      define_method(association.association_id) do |*params|
        get_associate(association, params) do
          has_one_associate(association)
        end
      end

      define_method("#{association.association_id}=") do |associate|
        set_associate(association, associate) do
          set_has_one_associate(association, associate)
        end
      end
    end

    # Specifies a one-to-one association with another class. This method should only be used
    # if this class contains the foreign key. If the other class contains the foreign key,
    # then you should use +t_has_one+ instead.
    #
    # Methods will be added for retrieval and query for a single associated object, for which
    # this object holds an id:
    #
    # [association(force_reload = false)]
    #   Returns the associated object. +nil+ is returned if none is found.
    # [association=(associate)]
    #   Assigns the associate object, extracts the primary key, and sets it as the foreign key.
    #
    # (+association+ is replaced with the symbol passed as the first argument, so
    # <tt>t_belongs_to :author</tt> would add among others <tt>author.nil?</tt>.)
    #
    # === Example
    #
    # A Post class declares <tt>t_belongs_to :author</tt>, which will add:
    # * <tt>Post#author</tt> (similar to <tt>Author.find(author_id)</tt>)
    # * <tt>Post#author=(author)</tt> (similar to <tt>post.author_id = author.id</tt>)
    #
    # === Supported options
    # [:class_name]
    #   Specify the class name of the association. Use it only if that name can't be inferred
    #   from the association name. So <tt>t_belongs_to :manager</tt> will by default be linked to the Manager class, but
    #   if the real class name is Person, you'll have to specify it with this option.
    #
    # Option examples:
    #   t_belongs_to :project_manager, :class_name => "Person"
    #
    def t_belongs_to(association_id, options={})
      extend(BelongsTo::ClassMethods)
      association = Association.new(association_id, options)
      initialize_belongs_to_association(association)

      define_method(association.association_id) do |*params|
        get_associate(association, params) do
          belongs_to_associate(association)
        end
      end

      define_method("#{association.association_id}=") do |associate|
        set_associate(association, associate) do
          set_belongs_to_associate(association, associate)
        end
      end
    end

    # Specifies a one-to-many association. The following methods for retrieval and query of
    # collections of associated objects will be added:
    #
    # [collection(force_reload = false)]
    #   Returns an array of all the associated objects.
    #   An empty array is returned if none are found.
    # [collection<<(object, ...)]
    #   Adds one or more objects to the collection by setting their foreign keys to the collection's primary key.
    #   Note that this operation does not update the association until the parent object is saved.
    # [collection.delete(object, ...)]
    #   Removes one or more objects from the collection.
    # [collection=objects]
    #   Replaces the collections content by setting it to the list of specified objects.
    # [collection_singular_ids]
    #   Returns an array of the associated objects' ids
    # [collection_singular_ids=ids]
    #   Replace the collection with the objects identified by the primary keys in +ids+.
    # [collection.clear]
    #   Removes every object from the collection.
    # [collection.empty?]
    #   Returns +true+ if there are no associated objects.
    # [collection.size]
    #   Returns the number of associated objects.
    #
    # (*Note*: +collection+ is replaced with the symbol passed as the first argument, so
    # <tt>t_has_many :clients</tt> would add among others <tt>clients.empty?</tt>.)
    #
    # === Example
    #
    # Example: A Firm class declares <tt>t_has_many :clients</tt>, which will add:
    # * <tt>Firm#clients</tt> (similar to <tt>Clients.find :all, :conditions => ["firm_id = ?", id]</tt>)
    # * <tt>Firm#clients<<</tt>
    # * <tt>Firm#clients.delete</tt>
    # * <tt>Firm#clients=</tt>
    # * <tt>Firm#client_ids</tt>
    # * <tt>Firm#client_ids=</tt>
    # * <tt>Firm#clients.clear</tt>
    # * <tt>Firm#clients.empty?</tt> (similar to <tt>firm.clients.size == 0</tt>)
    # * <tt>Firm#clients.size</tt> (similar to <tt>Client.count "firm_id = #{id}"</tt>)
    #
    # === Supported options
    # [:class_name]
    #   Specify the class name of the association. Use it only if that name can't be inferred
    #   from the association name. So <tt>t_has_many :products</tt> will by default be linked
    #   to the Product class, but if the real class name is SpecialProduct, you'll have to
    #   specify it with this option.
    #
    # Option examples:
    #   t_has_many :products, :class_name => "SpecialProduct"
    #
    def t_has_many(association_id, options={})
      extend(HasMany::ClassMethods)
      association = Association.new(association_id, options)
      initialize_has_many_association(association)

      define_method(association.association_id) do |*params|
        get_associate(association, params) do
          has_many_associates(association)
        end
      end

      define_method("#{association.association_id}=") do |associates|
        set_associate(association, associates)
      end

      define_method("#{ActiveSupport::Inflector.singularize(association.association_id)}_ids") do
        has_many_associate_ids(association)
      end

      define_method("#{ActiveSupport::Inflector.singularize(association.association_id)}_ids=") do |associate_ids|
        set_has_many_associate_ids(association, associate_ids)
      end

      private

      define_method(:_t_save_without_callback) do
        save_without_callback
      end
    end

  end
end

