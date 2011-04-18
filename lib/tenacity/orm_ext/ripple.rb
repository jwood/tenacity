module Tenacity
  module OrmExt
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
          super
          after_save
        end

        def destroy(run_callbacks=true)
          super()
          after_destroy if run_callbacks
        end

        def delete
          destroy(false)
        end

        private

        def after_save
          create_associate_indexes
          _t_save_autosave_associations

          associations = self.class._t_has_many_associations || []
          associations.each { |association| self.class._t_save_associates(self, association) }
        end

        def after_destroy
          delete_associate_indexes

          associations = self.class._t_belongs_to_associations || []
          associations.each { |association| self._t_cleanup_belongs_to_association(association) }

          associations = self.class._t_has_one_associations || []
          associations.each { |association| self._t_cleanup_has_one_association(association) }

          associations = self.class._t_has_many_associations || []
          associations.each { |association| self._t_cleanup_has_many_association(association) }
        end

        def create_associate_indexes
          associations = self.class._t_belongs_to_associations || []
          associations.each do |association|
            associate_id = self.send(association.foreign_key)
            create_associate_index(association, associate_id) unless associate_id.nil?
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

        def delete_associate_indexes
          associations = self.class._t_belongs_to_associations || []
          associations.each do |association|
            associate_id = self.send(association.foreign_key)
            delete_associate_index(association, associate_id) unless associate_id.nil?
          end
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


