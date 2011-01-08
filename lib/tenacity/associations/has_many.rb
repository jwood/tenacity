module Tenacity
  module HasMany #:nodoc:

    def _t_remove_associates(association)
      instance_variable_set _t_ivar_name(association), []
      _t_clear_associates(association)
    end

    private

    def has_many_associates(association)
      ids = _t_get_associate_ids(association)
      clazz = association.associate_class
      clazz._t_find_bulk(ids)
    end

    def has_many_associate_ids(association)
      _t_get_associate_ids(association)
    end

    def set_has_many_associate_ids(association, associate_ids)
      clazz = association.associate_class
      instance_variable_set _t_ivar_name(association), clazz._t_find_bulk(associate_ids)
    end

    def save_without_callback
      @perform_save_associates_callback = false
      save
    ensure
      @perform_save_associates_callback = true
    end

    module ClassMethods #:nodoc:
      def initialize_has_many_association(association)
        _t_initialize_has_many_association(association) if self.respond_to?(:_t_initialize_has_many_association)

        attr_accessor :perform_save_associates_callback
      end

      def _t_save_associates(record, association)
        return if record.perform_save_associates_callback == false

        _t_clear_old_associations(record, association)

        associates = (record.instance_variable_get record._t_ivar_name(association)) || []
        associates.each do |associate|
          associate.send("#{association.foreign_key(record.class)}=", record.id.to_s)
          save_associate(associate)
        end

        unless associates.blank?
          associate_ids = associates.map { |associate| associate.id.to_s }
          record._t_associate_many(association, associate_ids)
          save_associate(record)
        end
      end

      def _t_clear_old_associations(record, association)
        clazz = association.associate_class
        property_name = association.foreign_key(record.class)

        old_associates = clazz._t_find_all_by_associate(property_name, record.id.to_s)
        old_associates.each do |old_associate|
          old_associate.send("#{property_name}=", nil)
          save_associate(old_associate)
        end

        record._t_clear_associates(association)
        save_associate(record)
      end

      def save_associate(associate)
        associate.respond_to?(:_t_save_without_callback) ? associate._t_save_without_callback : associate.save
      end
    end

  end
end

