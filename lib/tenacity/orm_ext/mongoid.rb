module Tenacity
  module OrmExt
    # Tenacity relationships on Mongoid objects require no special keys
    # defined on the object.  Tenacity will define the keys that it needs
    # to support the relationships.  Take the following class for example:
    #
    #   class Car
    #     include Mongoid::Document
    #     include Tenacity
    #
    #     t_has_many    :wheels
    #     t_has_one     :dashboard
    #     t_belongs_to  :driver
    #   end
    #
    # == t_belongs_to
    #
    # The +t_belongs_to+ association will define a key named after the association.
    # The example above will create a key named <tt>:driver_id</tt>
    #
    #
    # == t_has_one
    #
    # The +t_has_one+ association will not define any new keys on the object, since
    # the associated object holds the foreign key.
    #
    #
    # == t_has_many
    #
    # The +t_has_many+ association will define a key named after the association.
    # The example above will create a key named <tt>:wheels_ids</tt>
    #
    module Mongoid

      def self.setup(model) #:nodoc:
        require 'mongoid'
        if model.included_modules.include?(::Mongoid::Document)
          model.send :include, Mongoid::InstanceMethods
          model.extend Mongoid::ClassMethods
        end
      rescue LoadError
        # Mongoid not available
      end

      module ClassMethods #:nodoc:
        include Tenacity::OrmExt::Helpers

        def _t_id_type
          String
        end

        def _t_find(id, association = nil)
          (id.nil? || id.to_s.strip == "") ? nil : find(_t_serialize(id))
        rescue ::Mongoid::Errors::DocumentNotFound
          nil
        end

        def _t_find_bulk(ids, association = nil)
          docs = find(_t_serialize_ids(ids))
          docs.respond_to?(:each) ? docs : [docs]
        rescue ::Mongoid::Errors::DocumentNotFound
          []
        end

        def _t_find_first_by_associate(property, id, association = nil)
          find(:first, :conditions => { property => _t_serialize(id) })
        end

        def _t_find_all_by_associate(property, id, association = nil)
          find(:all, :conditions => { property => _t_serialize(id) })
        end

        def _t_find_all_ids_by_associate(property, id, association = nil)
          results = collection.find({property => _t_serialize(id)}, {:fields => 'id'}).to_a
          results.map { |r| r['_id'] }
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
          unless self.respond_to?(association.foreign_key)
            field association.foreign_key, :type => id_class_for(association)
            field association.polymorphic_type, :type => String if association.polymorphic?
            after_destroy { |record| record._t_cleanup_belongs_to_association(association) }
          end
        end

        def _t_delete(ids, run_callbacks=true)
          docs = _t_find_bulk(ids)
          if run_callbacks
            docs.each { |doc| doc.destroy }
          else
            docs.each { |doc| doc.delete }
          end
        end
      end

      module InstanceMethods #:nodoc:
        def _t_reload
          reload
          self
        end

        def _t_save_if_dirty
          changed? ? save : false
        end
      end

    end
  end
end
