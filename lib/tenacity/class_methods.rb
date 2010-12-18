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
  # * <tt>Project#milestones.empty?, Project#milestones.size, Project#milestones, Project#milestones<<(milestone),</tt>
  #   <tt>Project#milestones.delete(milestone)
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
    def t_has_one(association_id, args={})
      define_method(association_id) do |*params|
        get_associate(association_id, params) do
          has_one_associate(association_id)
        end
      end

      define_method("#{association_id}=") do |associate|
        set_associate(association_id, associate) do
          set_has_one_associate(association_id, associate)
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
    # The declaration can also include an options hash to specialize the behavior of the association.
    #
    def t_belongs_to(association_id, args={})
      extend(BelongsTo::ClassMethods)

      _t_define_belongs_to_properties(association_id) if self.respond_to?(:_t_define_belongs_to_properties)

      define_method(association_id) do |*params|
        get_associate(association_id, params) do
          belongs_to_associate(association_id)
        end
      end

      define_method("#{association_id}=") do |associate|
        set_associate(association_id, associate) do
          set_belongs_to_associate(association_id, associate)
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
    #   Note that this operation instantly fires update sql without waiting for the save or update call on the
    #   parent object.
    # [collection.delete(object, ...)]
    #   Removes one or more objects from the collection by setting their foreign keys to +NULL+.
    # [collection=objects]
    #   Replaces the collections content by deleting and adding objects as appropriate.
    # [collection_singular_ids]
    #   Returns an array of the associated objects' ids
    # [collection_singular_ids=ids]
    #   Replace the collection with the objects identified by the primary keys in +ids+. This
    #   method loads the models and calls <tt>collection=</tt>. See above.
    # [collection.clear]
    #   Removes every object from the collection. This sets the foreign keys of the associated objects
    #   to +NULL+.
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
    # The declaration can also include an options hash to specialize the behavior of the association.
    #
    def t_has_many(association_id, args={})
      extend(HasMany::ClassMethods)

      attr_accessor "_t_" + association_id.to_s
      attr_accessor :perform_save_associates_callback

      _t_define_has_many_properties(association_id) if self.respond_to?(:_t_define_has_many_properties)

      define_method(association_id) do |*params|
        get_associate(association_id, params) do
          has_many_associates(association_id)
        end
      end

      define_method("#{association_id}=") do |associates|
        set_associate(association_id, associates)
      end

      define_method("#{ActiveSupport::Inflector.singularize(association_id.to_s)}_ids") do
        has_many_associate_ids(association_id)
      end

      define_method("#{ActiveSupport::Inflector.singularize(association_id.to_s)}_ids=") do |associate_ids|
        set_has_many_associate_ids(association_id, associate_ids)
      end

      private

      define_method(:_t_save_without_callback) do
        save_without_callback
      end
    end

  end
end

