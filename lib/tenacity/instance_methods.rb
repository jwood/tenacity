module Tenacity
  module InstanceMethods #:nodoc:

    def _t_ivar_name(association)
      "@_t_" + association.name.to_s
    end

    private

    def get_associate(association, params)
      _t_reload unless id.nil?
      force_reload = params.first unless params.empty?
      value = create_proxy(instance_variable_get(_t_ivar_name(association)), association)
      if value.nil? || force_reload
        value = create_proxy(yield, association)
        instance_variable_set _t_ivar_name(association), value
      end
      value
    end

    def set_associate(association, associate)
      yield if block_given?
      instance_variable_set _t_ivar_name(association), get_association_target(association, associate)
    end

    def create_proxy(value, association)
      if multiple_associates?(association, value)
        value.map! { |v| create_associate_proxy_for(v, association) }
        AssociatesProxy.new(self, value, association)
      else
        create_associate_proxy_for(value, association)
      end
    end

    def create_associate_proxy_for(value, association)
      value.nil? ? nil : AssociateProxy.new(value, association)
    end

    def get_association_target(association, associate)
      if multiple_associates?(association, associate)
        associate.map { |a| association_target(a) }
      else
        association_target(associate)
      end
    end

    def association_target(associate)
      associate.respond_to?(:association_target) ? associate.association_target : associate
    end

    def multiple_associates?(association, value)
      association.type == :t_has_many && value.is_a?(Enumerable)
    end

    def _t_serialize(object)
      self.class._t_serialize(object)
    end

  end
end
