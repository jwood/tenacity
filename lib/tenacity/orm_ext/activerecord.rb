module Tenacity
  module OrmExt
    # Tenacity relationships on ActiveRecord objects require that certain columns
    # exist on the associated table, and that join tables exist for one-to-many
    # relationships.  Take the following class for example:
    #
    #   class Car < ActiveRecord::Base
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
    #   create_table :cars do |t|
    #     t.string :driver_id
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
    #   create_table :cars_wheels do |t|
    #     t.integer :car_id
    #     t.string :wheel_id
    #   end
    #
    module ActiveRecord

      def self.setup(model)
        require 'active_record'
        if model.ancestors.include?(::ActiveRecord::Base)
          model.send :include, ActiveRecord::InstanceMethods
          model.extend ActiveRecord::ClassMethods
        end
      rescue LoadError
        # ActiveRecord not available
      end

      module ClassMethods #:nodoc:
        def _t_find(id)
          find_by_id(id)
        end

        def _t_find_bulk(ids)
          return [] if ids.nil? || ids.empty?
          find(:all, :conditions => ["id in (?)", ids])
        end

        def _t_find_first_by_associate(property, id)
          find(:first, :conditions => ["#{property} = ?", id.to_s])
        end

        def _t_find_all_by_associate(property, id)
          find(:all, :conditions => ["#{property} = ?", id.to_s])
        end

        def _t_initialize_has_many_association(association)
          after_save { |record| record.class._t_save_associates(record, association) }
        end

        def _t_initialize_belongs_to_association(association)
          before_save { |record| record.class._t_stringify_belongs_to_value(record, association) }
        end

        def _t_delete(ids, run_callbacks=true)
          if run_callbacks
            destroy_all(["id in (?)", ids])
          else
            delete_all(["id in (?)", ids])
          end
        end
      end

      module InstanceMethods #:nodoc:
        def _t_reload
          reload
        end

        def _t_clear_associates(association)
          self.connection.execute("delete from #{association.join_table} where #{association.association_key} = #{self.id}")
        end

        def _t_associate_many(association, associate_ids)
          self.transaction do
            _t_clear_associates(association)
            associate_ids.each do |associate_id|
              self.connection.execute("insert into #{association.join_table} (#{association.association_key}, #{association.association_foreign_key}) values (#{self.id}, '#{associate_id}')")
            end
          end
        end

        def _t_get_associate_ids(association)
          return [] if self.id.nil?
          rows = self.connection.execute("select #{association.association_foreign_key} from #{association.join_table} where #{association.association_key} = #{self.id}")
          ids = []; rows.each { |r| ids << r[0] }; ids
        end
      end

    end
  end
end
