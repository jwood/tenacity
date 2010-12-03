module TenacityPlugin
  module ClassMethods
    def _t_find(id)
      self.find(id)
    end
  end

  module InstanceMethods
  end
end

module TenacityPluginAddition
  def self.included(model)
    model.plugin TenacityPlugin
  end
end
MongoMapper::Document.append_inclusions(TenacityPluginAddition)

