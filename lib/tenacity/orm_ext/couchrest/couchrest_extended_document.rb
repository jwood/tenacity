begin
  require 'couchrest'

  module CouchRest #:nodoc:

    # Tenacity relationships on CouchRest objects require no special keys
    # defined on the object.  Tenacity will define the keys that it needs
    # to support the relationships.  Take the following class for example:
    #
    #   class Car < CouchRest::ExtendedDocument
    #     include Tenacity
    #
    #     t_has_many    :wheels
    #     t_has_one     :dashboard
    #     t_belongs_to  :driver
    #   end
    #
    # == t_belongs_to
    #
    # The +t_belongs_to+ association will define a property named after the association.
    # The example above will create a property named <tt>:driver_id</tt>
    #
    #
    # == t_has_one
    #
    # The +t_has_one+ association will not define any new properties on the object, since
    # the associated object holds the foreign key.  If the CouchRest::ExtendedDocument class
    # is the target of a t_has_one association from another class, then a property
    # named after the association will be created on the CouchRest::ExtendedDocument object to
    # hold the foreign key to the other object.
    #
    #
    # == t_has_many
    #
    # The +t_has_many+ association will define a property named after the association.
    # The example above will create a property named <tt>:wheels_ids</tt>
    #
    class ExtendedDocument
      include CouchRest::TenacityInstanceMethods
      extend CouchRest::TenacityClassMethods
    end
  end
rescue LoadError
  # CouchRest::ExtendedDocument not available
end
