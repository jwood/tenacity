module Tenacity
  module OrmExt
    # Tenacity relationships on Ripple objects require no special properties
    # defined on the object.  Tenacity will define the properties that it needs
    # to support the relationships.  Take the following class for example:
    #
    #   class Car
    #     include Ripple::Document
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
    # The example above will create a property named <tt>:driver_id</tt>  The +t_belongs_to+
    # relationship will also create a bucket in Riak that acts as an index to find
    # objects by their foreign key.  The bucket will be named after the Ripple class
    # and the name of the property used to store the foreign key.  In the above example,
    # the bucket will be named tenacity_car_driver_id.
    #
    #
    # == t_has_one
    #
    # The +t_has_one+ association will not define any new properties on the object, since
    # the associated object holds the foreign key.
    #
    #
    # == t_has_many
    #
    # The +t_has_many+ association will define a property named after the association.
    # The example above will create a property named <tt>:wheels_ids</tt>
    #
    module Ripple

      def self.setup(model) #:nodoc:
        require 'ripple'
        if model.included_modules.include?(::Ripple::Document)
          model.send :include, Ripple::InstanceMethods
          model.extend Ripple::ClassMethods
        end
      rescue LoadError
        # Ripple not available
      end

      module ClassMethods #:nodoc:
        include Tenacity::OrmExt::Helpers

        attr_accessor :_t_has_one_associations
        attr_accessor :_t_has_many_associations
        attr_accessor :_t_belongs_to_associations

        def _t_id_type
          String
        end

        def _t_find(id)
          find(_t_serialize(id))
        end

        def _t_find_bulk(ids)
          objects = find(_t_serialize_ids(ids)) || []
          objects = [objects] unless objects.respond_to?(:each)
          objects.reject(&:nil?)
        end

        def _t_find_first_by_associate(property, id)
          bucket = ::Ripple.client.bucket(_t_bucket_name(property))
          if bucket.exist?(id)
            object = bucket.get(id)
            find(object.data.first)
          else
            nil
          end
        end

        def _t_find_all_by_associate(property, id)
          bucket = ::Ripple.client.bucket(_t_bucket_name(property))
          if bucket.exist?(id)
            object = bucket.get(id)
            find(object.data)
          else
            []
          end
        end

        def _t_initialize_tenacity
        end

        def _t_initialize_has_one_association(association)
          @_t_has_one_associations ||= []
          @_t_has_one_associations << association
        end

        def _t_initialize_has_many_association(association)
          @_t_has_many_associations ||= []
          @_t_has_many_associations << association

          property association.foreign_keys_property, Array
        end

        def _t_initialize_belongs_to_association(association)
          @_t_belongs_to_associations ||= []
          @_t_belongs_to_associations << association

          property association.foreign_key, id_class_for(association)
          property association.polymorphic_type, String if association.polymorphic?
        end

        def _t_delete(ids, run_callbacks=true)
          docs = _t_find_bulk(ids)
          if run_callbacks
            docs.each { |doc| doc.destroy }
          else
            docs.each { |doc| doc.delete }
          end
        end

        private

        def _t_bucket_name(property_name)
          prefix = ENV['TENACITY_TEST'] == 'true' ? 'tenacity_test' : 'tenacity'
          "#{prefix}_#{ActiveSupport::Inflector.underscore(self.name)}_#{property_name.to_s}"
        end
      end

      module InstanceMethods #:nodoc:
        def id
          key
        end

        def _t_reload
          reload
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

        def save
          before_save
          super
          after_save
        end

        def destroy(run_callbacks=true)
          before_destroy if run_callbacks
          super()
          after_destroy if run_callbacks
        end

        def delete
          destroy(false)
        end

        private

        def before_save
          _t_verify_associates_exist
        end

        def after_save
          create_associate_indexes
          _t_save_autosave_associations

          associations = self.class._t_has_many_associations || []
          associations.each { |association| self.class._t_save_associates(self, association) }
        end

        def before_destroy
          associations = self.class._t_has_one_associations || []
          associations.each { |association| self._t_cleanup_has_one_association(association) }

          associations = self.class._t_has_many_associations || []
          associations.each { |association| self._t_cleanup_has_many_association(association) }
        end

        def after_destroy
          delete_associate_indexes

          associations = self.class._t_belongs_to_associations || []
          associations.each { |association| self._t_cleanup_belongs_to_association(association) }
        end

        def create_associate_indexes
          manage_associate_indexes(:create)
        end

        def delete_associate_indexes
          manage_associate_indexes(:delete)
        end

        def manage_associate_indexes(operation)
          associations = self.class._t_belongs_to_associations || []
          associations.each do |association|
            associate_id = self.send(association.foreign_key)
            unless associate_id.nil?
              if operation == :create
                create_associate_index(association, associate_id)
              else
                delete_associate_index(association, associate_id)
              end
            end
          end
        end

        def create_associate_index(association, associate_id)
          bucket = ::Ripple.client.bucket(self.class.send(:_t_bucket_name, association.foreign_key))
          if bucket.exist?(associate_id)
            object = bucket.get(associate_id)
            object.data << self.id
          else
            object = bucket.new(associate_id)
            object.data = [self.id]
          end
          object.store
        end

        def delete_associate_index(association, associate_id)
          bucket = ::Ripple.client.bucket(self.class.send(:_t_bucket_name, association.foreign_key))
          if bucket.exist?(associate_id)
            object = bucket.get(associate_id)
            object.data.delete(self.id)
            object.store
          end
        end
      end

    end
  end
end


