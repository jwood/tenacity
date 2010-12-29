begin
  require 'active_record'

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
    class Base #:nodoc:

      def self._t_find(id)
        find_by_id(id)
      end

      def self._t_find_bulk(ids)
        return [] if ids.nil? || ids.empty?
        find(:all, :conditions => ["id in (?)", ids])
      end

      def self._t_find_first_by_associate(property, id)
        find(:first, :conditions => ["#{property} = ?", id.to_s])
      end

      def self._t_find_all_by_associate(property, id)
        find(:all, :conditions => ["#{property} = ?", id.to_s])
      end

      def self._t_initialize_has_many_association(association_id)
        after_save { |record| record.class._t_save_associates(record, association_id) }
      end

      def self._t_initialize_belongs_to_association(association_id)
        before_save { |record| record.class._t_stringify_belongs_to_value(record, association_id) }
      end

      def _t_reload
        reload
      end

      def _t_clear_associates(association_id)
        t_join_table_name = self.class._t_join_table_name(association_id)
        self.connection.execute("delete from #{t_join_table_name} where #{self.class._t_my_id_column} = #{self.id}")
      end

      def _t_associate_many(association_id, associate_ids)
        t_join_table_name = self.class._t_join_table_name(association_id)
        values = associate_ids.map { |associate_id| "(#{self.id}, '#{associate_id}')" }.join(',')

        self.transaction do
          _t_clear_associates(association_id)
          self.connection.execute("insert into #{t_join_table_name} (#{self.class._t_my_id_column}, #{self.class._t_associate_id_column(association_id)}) values #{values}")
        end
      end

      def _t_get_associate_ids(association_id)
        t_join_table_name = self.class._t_join_table_name(association_id)
        rows = self.connection.execute("select #{self.class._t_associate_id_column(association_id)} from #{t_join_table_name} where #{self.class._t_my_id_column} = #{self.id}")
        ids = []; rows.each { |r| ids << r[0] }; ids
      end

      private

      def self._t_my_id_column
        table_name.singularize + '_id'
      end

      def self._t_associate_id_column(association_id)
        association_id.to_s.singularize + '_id'
      end

      def self._t_join_table_name(association_id)
        association_id.to_s < table_name ? "#{association_id}_#{table_name}" : "#{table_name}_#{association_id}"
      end

    end
  end
rescue LoadError
  # ActiveRecord not available
end
