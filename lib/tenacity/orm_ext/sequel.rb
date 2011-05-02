module Tenacity
  module OrmExt
    # Tenacity relationships on Sequel objects require that certain columns
    # exist on the associated table, and that join tables exist for one-to-many
    # relationships.  Take the following class for example:
    #
    #   class Car < Sequel::Model
    #     include Tenacity
    #
    #     t_has_many    :wheels
    #     t_has_one     :dashboard
    #     t_belongs_to  :driver
    #   end
    #
    #
    # == t_belongs_to
    #
    # The +t_belongs_to+ association requires that a property exist in the table
    # to hold the id of the assoicated object.
    #
    #   DB.create_table :cars do
    #     primary_key :id
    #     String :driver_id
    #   end
    #
    #
    # == t_has_one
    #
    # The +t_has_one+ association requires no special column in the table, since
    # the associated object holds the foreign key.
    #
    #
    # == t_has_many
    #
    # The +t_has_many+ association requires that a join table exist to store the
    # associations.  The name of the join table follows ActiveRecord conventions.
    # The name of the join table in this example would be cars_wheels, since cars
    # comes before wheels when shorted alphabetically.
    #
    #   DB.create_table :cars_wheels do
    #     Integer :car_id
    #     String :wheel_id
    #   end
    #
    module Sequel

      def self.setup(model)
        require 'sequel'
        if model.ancestors.include?(::Sequel::Model)
          model.send :include, Sequel::InstanceMethods
          model.extend Sequel::ClassMethods
        end
      rescue LoadError
        # Sequel not available
      end

      module ClassMethods #:nodoc:
        include Tenacity::OrmExt::Helpers

        attr_accessor :_t_has_one_associations
        attr_accessor :_t_has_many_associations
        attr_accessor :_t_belongs_to_associations

        def _t_id_type
          Integer
        end

        def _t_find(id)
          self[_t_serialize(id)]
        end

        def _t_find_bulk(ids)
          return [] if ids.nil? || ids.empty?
          filter(:id => _t_serialize_ids(ids)).to_a
        end

        def _t_find_first_by_associate(property, id)
          first(property.to_sym => _t_serialize(id))
        end

        def _t_find_all_by_associate(property, id)
          filter(property => _t_serialize(id)).to_a
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
        end

        def _t_initialize_belongs_to_association(association)
          @_t_belongs_to_associations ||= []
          @_t_belongs_to_associations << association
        end

        def _t_delete(ids, run_callbacks=true)
          if run_callbacks
            filter(:id => _t_serialize_ids(ids)).destroy
          else
            filter(:id => _t_serialize_ids(ids)).delete
          end
        end
      end

      module InstanceMethods #:nodoc:
        include Tenacity::OrmExt::Helpers

        def before_save
          _t_verify_associates_exist
          super
        end

        def after_save
          _t_save_autosave_associations

          associations = self.class._t_has_many_associations || []
          associations.each { |association| self.class._t_save_associates(self, association) }
          super
        end

        def before_destroy
          associations = self.class._t_has_one_associations || []
          associations.each { |association| self._t_cleanup_has_one_association(association) }
          super
        end

        def after_destroy
          associations = self.class._t_belongs_to_associations || []
          associations.each { |association| self._t_cleanup_belongs_to_association(association) }

          associations = self.class._t_has_many_associations || []
          associations.each { |association| self._t_cleanup_has_many_association(association) }
          super
        end

        def _t_reload
          reload
        end

        def _t_clear_associates(association)
          db["delete from #{association.join_table} where #{association.association_key} = #{_t_serialize_id_for_sql(self.id)}"].delete
        end

        def _t_associate_many(association, associate_ids)
          db.transaction do
            _t_clear_associates(association)
            associate_ids.each do |associate_id|
              db["insert into #{association.join_table} (#{association.association_key}, #{association.association_foreign_key}) values (#{_t_serialize_id_for_sql(self.id)}, #{_t_serialize_id_for_sql(associate_id)})"].insert
            end
          end
        end

        def _t_get_associate_ids(association)
          return [] if self.id.nil?
          rows = db["select #{association.association_foreign_key} from #{association.join_table} where #{association.association_key} = #{_t_serialize_id_for_sql(self.id)}"].all
          rows.map { |row| row[association.association_foreign_key.to_sym] }
        end
      end

    end
  end
end
