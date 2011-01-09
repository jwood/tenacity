module Tenacity
  # Tenacity relationships on MongoMapper objects require no special keys
  # defined on the object.  Tenacity will define the keys that it needs
  # to support the relationships.  Take the following class for example:
  #
  #   class Car < ActiveRecord::Base
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

    module ClassMethods #:nodoc:
      def _t_find(id)
        find(id)
      end

      def _t_find_bulk(ids=[])
        find(ids)
      end

      def _t_find_first_by_associate(property, id)
        first(property => id.to_s)
      end

      def _t_find_all_by_associate(property, id)
        all(property => id.to_s)
      end

      def _t_initialize_has_many_association(association)
        unless self.respond_to?(association.foreign_keys_property)
          key association.foreign_keys_property, Array
          after_save { |record| _t_save_associates(record, association) }
        end
      end

      def _t_initialize_belongs_to_association(association)
        unless self.respond_to?(association.foreign_key)
          key association.foreign_key, String
          before_save { |record| _t_stringify_belongs_to_value(record, association) }
        end
      end

      def _t_delete(ids, run_callbacks=true)
        if run_callbacks
          destroy(ids)
        else
          delete(ids)
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
        self.send(association.foreign_keys_property + '=', associate_ids.map { |associate_id| associate_id.to_s })
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
