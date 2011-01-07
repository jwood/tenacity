module Tenacity
  module InstanceMethods #:nodoc:

    def _t_ivar_name(association)
      "@_t_" + association.name.to_s
    end

    private

    def get_associate(association, params)
      _t_reload
      force_reload = params.first unless params.empty?
      value = instance_variable_get _t_ivar_name(association)
      if value.nil? || force_reload
        value = yield
        instance_variable_set _t_ivar_name(association), value
      end
      value
    end

    def set_associate(association, associate)
      yield if block_given?
      instance_variable_set _t_ivar_name(association), associate
    end

  end
end
