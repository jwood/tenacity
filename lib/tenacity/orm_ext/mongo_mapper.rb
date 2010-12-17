module TenacityPlugin
  module ClassMethods
    def _t_find(id)
      self.find(id)
    end

    def _t_find_bulk(ids=[])
      self.find(ids)
    end

    def _t_find_first_by_associate(property, id)
      self.first(property => id)
    end

    def _t_find_all_by_associate(property, id)
      self.all(property => id)
    end

    def _t_define_has_many_properties(association_id)
      key "_t_" + ActiveSupport::Inflector.singularize(association_id) + "_ids", Array
      after_save { |record| _t_save_associates(record, association_id) }
    end

    def _t_define_belongs_to_properties(association_id)
      key "#{association_id}_id", Integer
      before_save { |record| _t_stringify_belongs_to_value(record, association_id) }
    end
  end

  module InstanceMethods
    def _t_reload
      reload
    end

    def _t_associate_many(association_id, associate_ids)
      property_name = "_t_" + ActiveSupport::Inflector.singularize(association_id) + "_ids"
      self.send(property_name + '=', associate_ids)
    end

    def _t_get_associate_ids(association_id)
      property_name = "_t_" + ActiveSupport::Inflector.singularize(association_id) + "_ids"
      self.send(property_name)
    end

    def _t_clear_associates(association_id)
      property_name = "_t_" + ActiveSupport::Inflector.singularize(association_id) + "_ids"
      self.send(property_name + '=', [])
    end
  end
end

module TenacityPluginAddition
  def self.included(model)
    model.plugin TenacityPlugin
  end
end
MongoMapper::Document.append_inclusions(TenacityPluginAddition)

