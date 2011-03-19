module Tenacity
  # Associations are a set of macro-like class methods for tying objects together through
  # their ids. They express relationships like "Project has one Project Manager"
  # or "Project belongs to a Portfolio". Each macro adds a number of methods to the
  # class which are specialized according to the collection or association symbol and the
  # options hash. It works much the same way as Ruby's own <tt>attr*</tt>
  # methods.
  #
  #   class Project
  #     include SupportedDatabaseClient
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
  # == Is it a +t_belongs_to+ or +t_has_one+ association?
  #
  # Both express a 1-1 relationship. The difference is mostly where to place
  # the foreign key, which is owned by the class declaring the +t_belongs_to+
  # relationship.  Example:
  #
  #   class Employee < ActiveRecord::Base
  #     include Tenacity
  #     t_has_one :office
  #   end
  #
  #   class Office
  #     include MongoMapper::Document
  #     include Tenacity
  #     t_belongs_to :employee
  #   end
  #
  # In this example, the foreign key, <tt>employee_id</tt>, would belong to the
  # Office class.  If possible, tenacity will define the property to hold the
  # foreign key.  When it cannot, it assumes that the foreign key has been
  # defined.  See the documentation for the respective database client
  # extension to see if tenacity will declare the foreign_key property.
  #
  # == Unsaved objects and associations
  #
  # You can manipulate objects and associations before they are saved to the database, but there is some special behavior you should be
  # aware of, mostly involving the saving of associated objects.
  #
  # Unless you set the :autosave option on a <tt>t_has_one</tt>, <tt>t_belongs_to</tt>, or
  # <tt>t_has_many</tt> association. Setting it to +true+ will _always_ save the members,
  # whereas setting it to +false+ will _never_ save the members.
  #
  # === One-to-one associations
  #
  # * Assigning an object to a +t_has_one+ association automatically saves that object and the object being replaced (if there is one), in
  #   order to update their primary keys - except if the parent object is not yet stored in the database.
  # * Assigning an object to a +t_belongs_to+ association does not save the object, since the foreign key field belongs on the parent. It
  #   does not save the parent either.
  #
  # === Collections
  #
  # * Adding an object to a collection (+t_has_many+) automatically saves that object, except if the parent object
  #   (the owner of the collection) is not yet stored in the database.
  # * All unsaved members of the collection are automatically saved when the parent is saved.
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
  # == Join Tables
  #
  # One-to-many assocations that contain a relational database backed object as one of
  # the assocaites are implemented using an intermediate join table. This differs from
  # ActiveRecord::Associations, where only many-to-many relationships are implemented
  # using an intermediate join table.
  #
  # Tenacity will not create the join table. It assume one exists, and is named properly.
  # Unless the join table is explicitly specified as an option, it is guessed using the
  # lexical order of the class names. So a join between Developer and Project will give
  # the default join table name of "developers_projects" because "D" outranks "P". Note
  # that this precedence is calculated using the < operator for String. This means that
  # if the strings are of different lengths, and the strings are equal when compared up
  # to the shortest length, then the longer string is considered of higher lexical
  # precedence than the shorter one. For example, one would expect the tables "paper_boxes"
  # and "papers" to generate a join table name of "papers_paper_boxes" because of the
  # length of the name "paper_boxes", but it in fact generates a join table name of
  # "paper_boxes_papers". Be aware of this caveat, and use the custom :join_table option
  # if you need to.
  #
  # The column names used in the join table are guessed to be the names of the associated
  # classes, suffixed with "_id".  For example, the "developers_projects" join table
  # mentioned above is expected to have a column named "developer_id" and a column named
  # "project_id". The <tt>:associate_key</tt> and <tt>:associate_foreign_key</tt> options
  # can be used to override these defaults.
  #
  module ClassMethods
    attr_reader :_tenacity_associations

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
    # [:foreign_key]
    #   Specify the foreign key used for the association. By default this is guessed to be the name
    #   of this class in lower-case and "_id" suffixed. So a Person class that makes a +t_has_one+ association
    #   will use "person_id" as the default <tt>:foreign_key</tt>.
    # [:dependent]
    #   If set to <tt>:destroy</tt>, the associated object is deleted when this object is, and all delete
    #   callbacks are called.  If set to <tt>:delete</tt>, the associated object is deleted *without*
    #   calling any of its delete callbacks.  If set to <tt>:nullify</tt>, the associated object's
    #   foreign key is set to +NULL+.
    # [:readonly]
    #   If true, the associated object is readonly through the association.
    # [:autosave]
    #   If true, always save the associated object or destroy it if marked for destruction, when saving the parent object. Off by default.
    #
    # Option examples:
    #   t_has_one :credit_card, :dependent => :destroy  # destroys the associated credit card
    #   t_has_one :credit_card, :dependent => :nullify  # updates the associated records foreign key value to NULL rather than destroying it
    #   t_has_one :project_manager, :class_name => "Person"
    #   t_has_one :project_manager, :foreign_key => "project_id"  # within class named SecretProject
    #   t_has_one :boss, :readonly => :true
    #
    def t_has_one(name, options={})
      extend(Associations::HasOne::ClassMethods)
      association = _t_create_association(:t_has_one, name, options)
      initialize_has_one_association(association)

      define_method(association.name) do |*params|
        get_associate(association, params) do
          has_one_associate(association)
        end
      end

      define_method("#{association.name}=") do |associate|
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
    # [:foreign_key]
    #   Specify the foreign key used for the association. By default this is guessed to be the name
    #   of the association with an "_id" suffix. So a class that defines a <tt>t_belongs_to :person</tt>
    #   association will use "person_id" as the default <tt>:foreign_key</tt>. Similarly,
    #   <tt>t_belongs_to :favorite_person, :class_name => "Person"</tt> will use a foreign key
    #   of "favorite_person_id".
    # [:dependent]
    #   If set to <tt>:destroy</tt>, the associated object is deleted when this object is, calling all delete
    #   callbacks.  If set to <tt>:delete</tt>, the associated object is deleted *without* calling any of
    #   its delete callbacks.  This option should not be specified when <tt>t_belongs_to</tt> is used in
    #   conjuction with a <tt>t_has_many</tt> relationship on another class because of the potential
    #   to leave orphaned records behind.
    # [:readonly]
    #   If true, the associated object is readonly through the association.
    # [:autosave]
    #   If true, always save the associated object or destroy it if marked for destruction, when saving the parent object. Off by default.
    #
    # Option examples:
    #   t_belongs_to :project_manager, :class_name => "Person"
    #   t_belongs_to :valid_coupon, :class_name => "Coupon", :foreign_key => "coupon_id"
    #   t_belongs_to :project, :readonly => true
    #
    def t_belongs_to(name, options={})
      extend(Associations::BelongsTo::ClassMethods)
      association = _t_create_association(:t_belongs_to, name, options)
      initialize_belongs_to_association(association)

      define_method(association.name) do |*params|
        get_associate(association, params) do
          belongs_to_associate(association)
        end
      end

      define_method("#{association.name}=") do |associate|
        set_associate(association, associate) do
          set_belongs_to_associate(association, associate)
        end
      end
    end

    # Specifies a one-to-many association. One-to-many associations that contain a
    # relational database backed object as one of the associates are implemented
    # using an intermediate join table. See the Join Tables section at the top
    # for more information.
    #
    # The following methods for retrieval and query of collections of associated objects will be added:
    #
    # [collection(force_reload = false)]
    #   Returns an array of all the associated objects.
    #   An empty array is returned if none are found.
    # [collection<<(object, ...)]
    #   Adds one or more objects to the collection by setting their foreign keys to the collection's primary key.
    # [collection.push(object, ...)]
    #   Adds one or more objects to the collection by setting their foreign keys to the collection's primary key.
    # [collection.concat(other_array)]
    #   Adds the objects in the other array to the collection by setting their foreign keys to the collection's primary key.
    # [collection.delete(object, ...)]
    #   Removes one or more objects from the collection by setting their foreign keys to +NULL+.
    #   Objects will be in addition deleted and callbacks called if they're associated with <tt>:dependent => :destroy</tt>,
    #   and deleted and callbacks skipped if they're associated with <tt>:dependent => :delete_all</tt>.
    # [collection.destroy_all]
    #   Removes all objects from the collection, and deletes them from their respective
    #   database. If the deleted objects have any delete callbacks defined, they will be called.
    # [collection.delete_all]
    #   Removes all objects from the collection, and deletes them from their respective
    #   database. No delete callbacks will be called, regardless of whether or not they are defined.
    # [collection=objects]
    #   Replaces the collections content by setting it to the list of specified objects.
    # [collection_singular_ids]
    #   Returns an array of the associated objects' ids
    # [collection_singular_ids=ids]
    #   Replace the collection with the objects identified by the primary keys in +ids+.
    # [collection.clear]
    #   Removes every object from the collection. This deletes the associated objects and issues callbacks
    #   if they are associated with <tt>:dependent => :destroy</tt>, deletes them directly from the
    #   database without calling any callbacks if <tt>:dependent => :delete_all</tt>, otherwise sets their
    #   foreign keys to +NULL+.
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
    # [:foreign_key]
    #   Specify the foreign key used for the association. By default this is guessed to be the name
    #   of this class in lower-case and "_id" suffixed. So a Person class that makes a +t_has_many+
    #   association will use "person_id" as the default <tt>:foreign_key</tt>.
    # [:foreign_keys_property]
    #   Specify the name of the property that stores the ids of the associated objects. By default
    #   this is guessed to be the name of the association with a "t_" prefix and an "_ids" suffix.
    #   So a class that defines a <tt>t_has_many :people</tt> association will use t_people_ids as
    #   the property to store the ids of the associated People objects. This option is only valid
    #   for objects that store associated ids in an array instaed of a join table (CouchRest,
    #   MongoMapper, etc). <b>WARNING:</b> The name of the association with an "_ids" suffix should
    #   not be used as the property name, since tenacity adds a method with this name to the object.
    # [:dependent]
    #   If set to <tt>:destroy</tt> all the associated objects are deleted alongside this object
    #   in addition to calling their delete callbacks.  If set to <tt>:delete_all</tt> all
    #   associated objects are deleted *without* calling their delete callbacks.  If set to
    #   <tt>:nullify</tt> all associated objects' foreign keys are set to +NULL+ *without* calling
    #   their save backs.
    # [:join_table]
    #   Specify the name of the join table if the default based on lexical order isn't what you want.
    #   This option is only valid if one of the models in the association is backed by a relational
    #   database.
    # [:association_foreign_key]
    #   Specify the foreign key in the join table used for the association on the receiving side of
    #   the association. By default this is guessed to be the name of the associated class in
    #   lower-case and "_id" suffixed. So if a Person class makes a +t_has_many+ association to
    #   Project, the association will use "project_id" as the default <tt>:association_foreign_key</tt>.
    #   This option is only valid if one of the associated objects is backed by a relational
    #   database.
    # [:association_key]
    #   Specify the key in the join table used for the association on the declaring side of
    #   the association. By default this is guessed to be the name of this class in lower-case and
    #   "_id" suffixed. So if a Person class makes a +t_has_many+ association to Project, the
    #   association will use "person_id" as the default <tt>:association_key</tt>.  This option is
    #   only valid if one of the associated objects is backed by a relational database.
    # [:readonly]
    #   If true, all the associated objects are readonly through the association.
    # [:limit]
    #   An integer determining the limit on the number of rows that should be returned. Results
    #   are ordered by a string representation of the id.
    # [:offset]
    #   An integer determining the offset from where the rows should be fetched. So at 5, it would skip the first 4 rows.
    #   Results are ordered by a string representation of the id.
    # [:autosave]
    #   If true, always save any loaded members and destroy members marked for destruction, when saving the parent object. Off by default.
    #
    # Option examples:
    #   t_has_many :products, :class_name => "SpecialProduct"
    #   t_has_many :engineers, :foreign_key => "project_id"  # within class named SecretProject
    #   t_has_many :engineers, :foreign_keys_property => "worker_ids"
    #   t_has_many :managers, :join_table => "project_managers_and_projects"
    #   t_has_many :managers, :join_table => "project_managers_and_projects",
    #       :association_foreign_key => "mgr_id", :association_key => "proj_id"
    #   t_has_many :tasks, :dependent => :destroy
    #   t_has_many :reports, :readonly => true
    #
    def t_has_many(name, options={})
      extend(Associations::HasMany::ClassMethods)
      association = _t_create_association(:t_has_many, name, options)
      initialize_has_many_association(association)

      define_method(association.name) do |*params|
        get_associate(association, params) do
          has_many_associates(association)
        end
      end

      define_method("#{association.name}=") do |associates|
        set_associate(association, associates) do
          set_has_many_associates(association, associates)
        end
      end

      define_method("#{ActiveSupport::Inflector.singularize(association.name)}_ids") do
        has_many_associate_ids(association)
      end

      define_method("#{ActiveSupport::Inflector.singularize(association.name)}_ids=") do |associate_ids|
        set_has_many_associate_ids(association, associate_ids)
      end

      private

      define_method(:_t_save_without_callback) do
        save_without_callback
      end
    end

    def _t_serialize(object_id) #:nodoc:
      if object_id.nil?
        nil
      elsif [Fixnum].include?(object_id.class)
        object_id
      else
        object_id.to_s
      end
    end

    private

    def _t_create_association(type, name, options) #:nococ:
      association = Association.new(type, name, self, options)
      @_tenacity_associations ||= []
      @_tenacity_associations << association
      association
    end

  end
end

