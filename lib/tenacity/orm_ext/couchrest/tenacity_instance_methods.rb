module CouchRest
  module TenacityInstanceMethods #:nodoc:
    def _t_reload
      new_doc = database.get(self.id)
      self.clear
      new_doc.each { |k,v| self[k] = new_doc[k] }
    end

    def _t_associate_many(association_id, associate_ids)
      self.send(has_many_property_name(association_id) + '=', associate_ids.map { |associate_id| associate_id.to_s })
    end

    def _t_get_associate_ids(association_id)
      self.send(has_many_property_name(association_id)) || []
    end

    def _t_clear_associates(association_id)
      self.send(has_many_property_name(association_id) + '=', [])
    end
  end
end
