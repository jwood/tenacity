module Tenacity
  module OrmExt
    # Tenacity relationships on MongoMapper objects require no special keys
    # defined on the object.  Tenacity will define the keys that it needs
    # to support the relationships.  Take the following class for example:
    #
    #   class Car
    #     include MongoMapper::Document
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
    module MongoMapper

      def self.setup(model) #:nodoc:
        require 'mongo_mapper'
        if model.included_modules.include?(::MongoMapper::Document)
          model.send :include, MongoMapper::InstanceMethods
          model.extend MongoMapper::ClassMethods
        end
      rescue LoadError
        # MongoMapper not available
      end

      module ClassMethods #:nodoc:
        include Tenacity::OrmExt::Helpers

        def _t_id_type
          String
        end

        def _t_find(id)
          find(_t_serialize(id))
        end

        def _t_find_bulk(ids=[])
          find(_t_serialize_ids(ids))
        end

        def _t_find_first_by_associate(property, id)
          first(property => _t_serialize(id))
        end

        def _t_find_all_by_associate(property, id)
          all(property => _t_serialize(id))
        end

        def _t_initialize_tenacity
          before_save { |record| record._t_verify_associates_exist }
          after_save { |record| record._t_save_autosave_associations }
        end

        def _t_initialize_has_one_association(association)
          before_destroy { |record| record._t_cleanup_has_one_association(association) }
        end

        def _t_initialize_has_many_association(association)
          unless self.respond_to?(association.foreign_keys_property)
            key association.foreign_keys_property, Array
            after_save { |record| record.class._t_save_associates(record, association) }
            after_destroy { |record| record._t_cleanup_has_many_association(association) }
          end
        end

        def _t_initialize_belongs_to_association(association)
          unless self.respond_to?(association.foreign_key)
            key association.foreign_key, id_class_for(association)
            key association.polymorphic_type, String if association.polymorphic?
            after_destroy { |record| record._t_cleanup_belongs_to_association(association) }
          end
        end

        def _t_delete(ids, run_callbacks=true)
          if run_callbacks
            destroy(_t_serialize_ids(ids))
          else
            delete(_t_serialize_ids(ids))
          end
        end
      end

      module InstanceMethods #:nodoc:
        def _t_reload
          reload
        rescue ::MongoMapper::DocumentNotFound
          nil
        end

        def _t_associate_many(association, associate_ids)
          self.send(association.foreign_keys_property + '=', associate_ids)
        end

        def _t_get_associate_ids(association)
          self.send(association.foreign_keys_property)
        end

        def _t_clear_associates(association)
          self.send(association.foreign_keys_property + '=', [])
        end
      end

    end
  end
end
