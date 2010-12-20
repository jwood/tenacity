module CouchRest
  class ExtendedDocument #:nodoc:
    def self._t_find(id)
      get(id)
    end

    def self._t_find_bulk(ids)
      return [] if ids.nil? || ids.empty?

      docs = []
      result = database.get_bulk ids
      result['rows'].each do |row|
        docs << (row['doc'].nil? ? nil : create_from_database(row['doc']))
      end
      docs.reject { |doc| doc.nil? }
    end

    def self._t_find_first_by_associate(property, id)
      self.send("by_#{property}", :key => id.to_s).first
    end

    def self._t_find_all_by_associate(property, id)
      self.send("by_#{property}", :key => id.to_s)
    end

    def self._t_initialize_has_many_association(association_id)
      unless self.respond_to?(has_many_property_name(association_id))
        property has_many_property_name(association_id), :type => 'Array'
        view_by has_many_property_name(association_id)
        after_save { |record| _t_save_associates(record, association_id) if self.respond_to?(:_t_save_associates) }
      end
    end

    def self._t_initialize_belongs_to_association(association_id)
      property_name = "#{association_id}_id"
      unless self.respond_to?(property_name)
        property property_name, :type => 'String'
        view_by property_name
        before_save { |record| _t_stringify_belongs_to_value(record, association_id) if self.respond_to?(:_t_stringify_belongs_to_value) }
      end
    end

    def self._t_initialize_has_one_association(association_id)
      property_name = "#{association_id}_id"
      unless self.respond_to?(property_name)
        property property_name, :type => 'String'
        view_by property_name
        before_save { |record| _t_stringify_has_one_value(record, association_id) if self.respond_to?(:_t_stringify_has_one_value) }
      end
    end

    def _t_reload
      new_doc = database.get(self.id)
      self.clear
      new_doc.each { |k,v| self[k] = new_doc[k] }
    end

    def _t_associate_many(association_id, associate_ids)
      self.send(has_many_property_name(association_id) + '=', associate_ids)
    end

    def _t_get_associate_ids(association_id)
      self.send(has_many_property_name(association_id)) || []
    end

    def _t_clear_associates(association_id)
      self.send(has_many_property_name(association_id) + '=', [])
    end

  end
end

