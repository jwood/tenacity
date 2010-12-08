require 'active_support/inflector'

module ActiveRecord
  class Base
    def self._t_find(id)
      self.find_by_id(id)
    end

    def self._t_find_all_by_associate(property, id)
      find(:all, :conditions => ["#{property} = ?", id])
    end

    def _t_associate_many(association_id, associate_ids)
      join_table_name = _t_join_table_name(association_id)
      values = associate_ids.map { |associate_id| "(#{self.id}, '#{associate_id}')" }.join(',')

      self.transaction do
        self.connection.execute("delete from #{join_table_name} where #{my_id_column} = #{self.id}")
        self.connection.execute("insert into #{join_table_name} (#{my_id_column}, #{associate_id_column(association_id)}) values #{values}")
      end
    end

    def _t_get_associate_ids(association_id)
      join_table_name = _t_join_table_name(association_id)
      rows = self.connection.execute("select #{associate_id_column(association_id)} from #{join_table_name} where #{my_id_column} = #{self.id}")
      ids = []; rows.each { |r| ids << r[0] }; ids
    end

    private

      def _t_table_name
        @@_t_table_name ||= self.class.table_name
      end

      def my_id_column
        _t_table_name.singularize + '_id'
      end

      def associate_id_column(association_id)
        association_id.to_s.singularize + '_id'
      end

      def _t_join_table_name(association_id)
        association_id.to_s < _t_table_name ? "#{association_id}_#{_t_table_name}" : "#{_t_table_name}_#{association_id}"
      end
  end
end
