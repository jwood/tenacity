module Tenacity
  module OrmExt
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
    # the associated object holds the foreign key.
    #
    #
    # == t_has_many
    #
    # The +t_has_many+ association will define a property named after the association.
    # The example above will create a property named <tt>:wheels_ids</tt>
    #
    module CouchRest

      def self.setup(model) #:nodoc:
        begin
          require 'couchrest_model'
          if model.ancestors.include?(::CouchRest::Model::Base)
            model.send :include, CouchRest::InstanceMethods
            model.extend CouchRest::ClassMethods
          end
        rescue LoadError
          # CouchRest::Model not available
        end

        begin
          require 'couchrest_extended_document'
          if model.ancestors.include?(::CouchRest::ExtendedDocument)
            model.send :include, CouchRest::InstanceMethods
            model.extend CouchRest::ClassMethods
          end
        rescue LoadError
          # CouchRest::ExtendedDocument not available
        end

        # For pre 1.0 versions of couchrest
        begin
          require 'couchrest'
          if model.ancestors.include?(::CouchRest::ExtendedDocument)
            model.send :include, CouchRest::InstanceMethods
            model.extend CouchRest::ClassMethods
          end
        rescue LoadError
        rescue NameError
          # CouchRest::ExtendedDocument not available
        end
      end

      module ClassMethods #:nodoc:
        include Tenacity::OrmExt::Helpers

        def _t_id_type
          String
        end

        def _t_find(id)
          (id.nil? || id.strip == "") ? nil : get(_t_serialize(id))
        end

        def _t_find_bulk(ids)
          return [] if ids.nil? || ids.empty?
          ids = [ids] unless ids.class == Array

          docs = []
          result = database.get_bulk(_t_serialize_ids(ids))
          result['rows'].each do |row|
            docs << (row['doc'].nil? ? nil : create_from_database(row['doc']))
          end
          docs.reject { |doc| doc.nil? }
        end

        def _t_find_first_by_associate(property, id)
          self.send("by_#{property}", :key => _t_serialize(id)).first
        end

        def _t_find_all_by_associate(property, id)
          self.send("by_#{property}", :key => _t_serialize(id))
        end

        def _t_find_all_ids_by_associate(property, id)
          results = self.send("by_#{property}", :key => _t_serialize(id), :include_docs => false)
          results['rows'].map { |r| r['id'] }
        end

        def _t_initialize_tenacity
          before_save { |record| record._t_verify_associates_exist }
          after_save { |record| record._t_save_autosave_associations }
        end

        def _t_initialize_has_one_association(association)
          before_destroy { |record| record._t_cleanup_has_one_association(association) }
        end

        def _t_initialize_has_many_association(association)
          after_save { |record| record.class._t_save_associates(record, association) }
          before_destroy { |record| record._t_cleanup_has_many_association(association) }
        end

        def _t_initialize_belongs_to_association(association)
          property_name = association.foreign_key
          unless self.respond_to?(property_name)
            property property_name, :type => id_class_for(association)
            property association.polymorphic_type, :type => String if association.polymorphic?
            view_by property_name
            after_destroy { |record| record._t_cleanup_belongs_to_association(association) }
          end
        end

        def _t_delete(ids, run_callbacks=true)
          docs = _t_find_bulk(ids)
          if run_callbacks
            docs.each { |doc| doc.destroy }
          else
            docs.each { |doc| database.delete_doc(doc) }
          end
        end
      end

      module InstanceMethods #:nodoc:
        def _t_reload
          return if self.id.nil?
          new_doc = database.get(self.id)
          self.clear
          new_doc.each { |k,v| self[k] = new_doc[k] }
        end
      end

    end
  end
end
