module ActiveRecord
  class Base

    def self._t_find(id)
      self.find_by_id(id)
    end

    def self._t_find_bulk(ids)
      self.find(ids)
    end

    def self._t_find_all_by_associate(property, id)
      find(:all, :conditions => ["#{property} = ?", id])
    end

    def self._t_define_has_many_properties(association_id)
      after_save { |record| _t_save_associates(record, association_id) }
    end

    def self._t_define_belongs_to_properties(association_id)
      before_save { |record| _t_stringify_belongs_to_value(record, association_id) }
    end

    def _t_clear_associates(association_id)
      join_table_name = self.class._t_join_table_name(association_id)
      self.connection.execute("delete from #{join_table_name} where #{self.class._t_my_id_column} = #{self.id}")
    end

    def _t_associate_many(association_id, associate_ids)
      join_table_name = self.class._t_join_table_name(association_id)
      values = associate_ids.map { |associate_id| "(#{self.id}, '#{associate_id}')" }.join(',')

      self.transaction do
        _t_clear_associates(association_id)
        self.connection.execute("insert into #{join_table_name} (#{self.class._t_my_id_column}, #{self.class._t_associate_id_column(association_id)}) values #{values}")
      end
    end

    def _t_get_associate_ids(association_id)
      join_table_name = self.class._t_join_table_name(association_id)
      rows = self.connection.execute("select #{self.class._t_associate_id_column(association_id)} from #{join_table_name} where #{self.class._t_my_id_column} = #{self.id}")
      ids = []; rows.each { |r| ids << r[0] }; ids
    end

    private

      def self._t_table_name
        @@_t_table_name ||= table_name
      end

      def self._t_my_id_column
        _t_table_name.singularize + '_id'
      end

      def self._t_associate_id_column(association_id)
        association_id.to_s.singularize + '_id'
      end

      def self._t_join_table_name(association_id)
        association_id.to_s < _t_table_name ? "#{association_id}_#{_t_table_name}" : "#{_t_table_name}_#{association_id}"
      end
  end
end
