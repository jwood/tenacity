module TenacityPlugin
  module ClassMethods
    def _t_find(id)
      self.find(id)
    end

    def _t_find_associates(property, id)
      self.all(property => id)
    end
  end

  module InstanceMethods
    def _t_associate_many(association_id, associates)
      associate_ids = associates.map { |a| a.id }
      property_name = ActiveSupport::Inflector.singularize(association_id) + "_ids"
      self.send(property_name + '=', associate_ids)
      self.save
    end
  end
end

module TenacityPluginAddition
  def self.included(model)
    model.plugin TenacityPlugin
  end
end
MongoMapper::Document.append_inclusions(TenacityPluginAddition)

