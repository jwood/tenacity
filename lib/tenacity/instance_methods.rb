module Tenacity
  module InstanceMethods #:nodoc:

    def _t_ivar_name(association)
      "@_t_" + association.name.to_s
    end

    def _t_save_autosave_associations
      self.class._tenacity_associations.select { |a| a.autosave == true }.each do |association|
        if association.type == :t_has_one || association.type == :t_belongs_to
          associate = instance_variable_get(_t_ivar_name(association))
          autosave_save_or_destroy(associate) unless associate.nil?
        elsif association.type == :t_has_many
          associates = instance_variable_get(_t_ivar_name(association))
          unless associates.nil?
            associates.each { |associate| autosave_save_or_destroy(associate) }
            instance_variable_set(_t_ivar_name(association), associates.reject { |associate| associate.marked_for_destruction? })
          end
        end
      end
    end

    def _t_verify_associates_exist
      associations_requiring_associate_validation.each do |association|
        associate_id = self.send(association.foreign_key)
        unless associate_id.nil?
          associate_class = association.associate_class(self)
          associate = associate_class._t_find(_t_serialize(associate_id, association))
          raise ObjectDoesNotExistError.new("#{associate_class} object with an id of #{associate_id} does not exist!") if associate.nil?
        end
      end
    end

    private

    def autosave_save_or_destroy(associate)
      associate.marked_for_destruction? ? associate.destroy : associate.save
    end

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
      associate = yield if block_given?
      instance_variable_set _t_ivar_name(association), create_proxy(associate, association)
    end

    def create_proxy(value, association)
      return value if value.respond_to?(:proxy_respond_to?)

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

    def multiple_associates?(association, value)
      association.type == :t_has_many && value.is_a?(Enumerable)
    end

    def _t_serialize(object, association=nil)
      self.class._t_serialize(object, association)
    end

    def associations_requiring_associate_validation
      self.class._tenacity_associations.select { |a| !a.disable_foreign_key_constraints? && a.type == :t_belongs_to }
    end

  end
end
