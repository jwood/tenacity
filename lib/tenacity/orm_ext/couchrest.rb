module CouchRest
  class ExtendedDocument #:nodoc:
    def self._t_find(id)
      get(id)
    end

    def self._t_find_bulk(ids)
      #return [] if ids.nil? || ids.empty?
      #find(:all, :conditions => ["id in (?)", ids])
    end

    def self._t_find_first_by_associate(property, id)
      #find(:first, :conditions => ["#{property} = ?", id.to_s])
    end

    def self._t_find_all_by_associate(property, id)
      #find(:all, :conditions => ["#{property} = ?", id.to_s])
    end

    def self._t_initialize_has_many_association(association_id)
      #after_save { |record| _t_save_associates(record, association_id) }
    end

    def self._t_initialize_belongs_to_association(association_id)
      #before_save { |record| _t_stringify_belongs_to_value(record, association_id) }
    end

    def _t_reload
      #reload
    end

    def _t_clear_associates(association_id)
      #join_table_name = self.class.join_table_name(association_id)
      #self.connection.execute("delete from #{join_table_name} where #{self.class.my_id_column} = #{self.id}")
    end

    def _t_associate_many(association_id, associate_ids)
      #join_table_name = self.class.join_table_name(association_id)
      #values = associate_ids.map { |associate_id| "(#{self.id}, '#{associate_id}')" }.join(',')

      #self.transaction do
      #  _t_clear_associates(association_id)
      #  self.connection.execute("insert into #{join_table_name} (#{self.class.my_id_column}, #{self.class.associate_id_column(association_id)}) values #{values}")
      #end
    end

    def _t_get_associate_ids(association_id)
      #join_table_name = self.class.join_table_name(association_id)
      #rows = self.connection.execute("select #{self.class.associate_id_column(association_id)} from #{join_table_name} where #{self.class.my_id_column} = #{self.id}")
      #ids = []; rows.each { |r| ids << r[0] }; ids
    end
  end
end

