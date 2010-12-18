# Tenacity relationships on MongoMapper objects require no special keys
# defined on the object.  Tenacity will define the keys that it needs
# to support the relationships.  Take the following class for example:
#
#   class Car < ActiveRecord::Base
#     include MongoMapper::Document
#     include Tenacity
#
#     t_has_many    :wheels
#     t_has_one     :dashboard
#     t_belongs_to  :driver
#   end
#
# == t_belongs_to
#
# The +t_belongs_to+ association will define a key named after the association.
# The example above will create a key named <tt>:driver_id</tt>
#
#
# == t_has_one
#
# The +t_has_one+ association will not define any new keys on the object, since
# the associated object holds the foreign key.  The the MongoMapper class
# is the target of a t_has_one association from another class, then a property
# named after the association will be created on the MongoMapper object to
# hold the foreign key to the other object.
#
#
# == t_has_many
#
# The +t_has_many+ association will define a key named after the association.
# The example above will create a key named <tt>:wheels_ids</tt>
#
module TenacityMongoMapperPlugin
  module ClassMethods #:nodoc:
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

    def _t_define_has_one_properties(association_id)
      unless self.respond_to?("#{association_id}_id")
        key "#{association_id}_id", String
        before_save { |record| _t_stringify_has_one_value(record, association_id) }
      end
    end
  end

  module InstanceMethods #:nodoc:
    def _t_reload
      reload
    rescue
      nil
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

module TenacityPluginAddition #:nodoc:
  def self.included(model)
    model.plugin TenacityMongoMapperPlugin
  end
end
MongoMapper::Document.append_inclusions(TenacityPluginAddition)

