module ActiveRecord
  class Base
    def self._t_find(id)
      self.find_by_id(id)
    end
  end
end
