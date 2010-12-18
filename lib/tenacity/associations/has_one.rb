module Tenacity
  module HasOne #:nodoc:

    private

    def has_one_associate(association_id)
      clazz = Kernel.const_get(association_id.to_s.camelcase.to_sym)
      clazz._t_find_first_by_associate("#{ActiveSupport::Inflector.underscore(self.class.to_s)}_id", self.id.to_s)
    end

    def set_has_one_associate(association_id, associate)
      associate.send "#{ActiveSupport::Inflector.underscore(self.class.to_s)}_id=", self.id.to_s
      associate.save
    end

  end
end

