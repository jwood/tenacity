module TenacityPlugin
  module ClassMethods
    def _t_find(id)
      self.find(id)
    end

    def _t_find_all_by_associate(property, id)
      self.all(property => id)
    end
  end

  module InstanceMethods
    def _t_associate_many(association_id, associate_ids)
      property_name = "_t_" + ActiveSupport::Inflector.singularize(association_id) + "_ids"
      self.send(property_name + '=', associate_ids)
      self.save
    end

    def _t_get_associate_ids(association_id)
      property_name = "_t_" + ActiveSupport::Inflector.singularize(association_id) + "_ids"
      self.send(property_name)
    end
  end
end

module TenacityPluginAddition
  def self.included(model)
    model.plugin TenacityPlugin
  end
end
MongoMapper::Document.append_inclusions(TenacityPluginAddition)

