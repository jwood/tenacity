module CouchRest
  module TenacityClassMethods #:nodoc:
    def _t_find(id)
      get(id)
    end

    def _t_find_bulk(ids)
      return [] if ids.nil? || ids.empty?

      docs = []
      result = database.get_bulk ids
      result['rows'].each do |row|
        docs << (row['doc'].nil? ? nil : create_from_database(row['doc']))
      end
      docs.reject { |doc| doc.nil? }
    end

    def _t_find_first_by_associate(property, id)
      self.send("by_#{property}", :key => id.to_s).first
    end

    def _t_find_all_by_associate(property, id)
      self.send("by_#{property}", :key => id.to_s)
    end

    def _t_initialize_has_many_association(association)
      unless self.respond_to?(association.foreign_keys_property)
        property association.foreign_keys_property, :type => [String]
        view_by association.foreign_keys_property
        after_save { |record| record.class._t_save_associates(record, association) if record.class.respond_to?(:_t_save_associates) }
      end
    end

    def _t_initialize_belongs_to_association(association)
      property_name = association.foreign_key
      unless self.respond_to?(property_name)
        property property_name, :type => String
        view_by property_name
        before_save { |record| _t_stringify_belongs_to_value(record, association) if self.respond_to?(:_t_stringify_belongs_to_value) }
      end
    end
  end
end
