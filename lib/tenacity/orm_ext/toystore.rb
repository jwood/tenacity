module Tenacity
  module OrmExt
    #
    # Tenacity relationships on Toystore objects require no special attributes
    # defined on the object.  Tenacity will define the attributes that it needs
    # to support the relationships.  Take the following class for example:
    #
    #   class Car
    #     include Toy::Store
    #     store :mongo, Mongo::Connection.new.db('tenacity')['toystore']
    #     include Tenacity
    #
    #     t_has_many    :wheels
    #     t_has_one     :dashboard
    #     t_belongs_to  :driver
    #   end
    #
    # <b>Please note that the data store must be established before including the Tenacity module.</b>
    #
    # == t_belongs_to
    #
    # The +t_belongs_to+ association will define an attribute named after the association.
    # The example above will create an attribute named <tt>:driver_id</tt>
    #
    #
    # == t_has_one
    #
    # The +t_has_one+ association will not define any new attributes on the object, since
    # the associated object holds the foreign key.
    #
    #
    # == t_has_many
    #
    # The +t_has_many+ association will define an attribute named after the association.
    # The example above will create attribute named <tt>:wheels_ids</tt>
    #
    module Toystore

      def self.setup(model) #:nodoc:
        require 'toystore'
        if model.included_modules.include?(::Toy::Store)
          model.send :include, Toystore::InstanceMethods
          model.extend Toystore::ClassMethods
        end
      rescue LoadError
        # Toystore not available
      end

      module ClassMethods #:nodoc:
        include Tenacity::OrmExt::Helpers

        def _t_id_type
          String
        end

        def _t_find(id, association = nil)
          (id.nil? || id.to_s.strip == "") ? nil : get(_t_serialize(id))
        end

        def _t_find_bulk(ids, association = nil)
          get_multi(_t_serialize_ids(ids)).compact
        end

        def _t_find_first_by_associate(property, id, association = nil)
          send("first_by_#{property}", id)
        end

        def _t_find_all_by_associate(property, id, association = nil)
          get_multi(_t_find_all_ids_by_associate(property, id, association))
        end

        def _t_find_all_ids_by_associate(property, id, association = nil)
          get_index(property.to_sym, id)
        end

        def _t_initialize_tenacity
          before_save { |record| record._t_verify_associates_exist }
          after_save { |record| record._t_save_autosave_associations }
        end

        def _t_initialize_has_one_association(association)
          before_destroy { |record| record._t_cleanup_has_one_association(association) }
        end

        def _t_initialize_has_many_association(association)
          after_save { |record| self.class._t_save_associates(record, association) }
          before_destroy { |record| record._t_cleanup_has_many_association(association) }
        end

        def _t_initialize_belongs_to_association(association)
          attribute association.foreign_key, id_class_for(association)
          attribute association.polymorphic_type, String if association.polymorphic?
          index(association.foreign_key.to_sym)
          after_destroy { |record| record._t_cleanup_belongs_to_association(association) }
        end

        def _t_delete(ids, run_callbacks=true)
          if run_callbacks
            destroy(*ids)
          else
            delete(*ids)
          end
        end
      end

      module InstanceMethods #:nodoc:
        def _t_reload
          reload
          self
        end

        def _t_save_if_dirty(*args)
          changed? ? save(*args) : true
        end
      end
    end
  end
end
