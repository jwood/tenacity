module CouchRest
  module TenacityInstanceMethods #:nodoc:
    def _t_reload
      new_doc = database.get(self.id)
      self.clear
      new_doc.each { |k,v| self[k] = new_doc[k] }
    end

    def _t_associate_many(association, associate_ids)
      self.send(has_many_property_name(association) + '=', associate_ids.map { |associate_id| associate_id.to_s })
    end

    def _t_get_associate_ids(association)
      self.send(has_many_property_name(association)) || []
    end

    def _t_clear_associates(association)
      self.send(has_many_property_name(association) + '=', [])
    end
  end
end
