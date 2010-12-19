module Tenacity
  module HasMany #:nodoc:

    private

    def has_many_associates(association_id)
      ids = _t_get_associate_ids(association_id)
      clazz = associate_class(association_id)
      clazz._t_find_bulk(ids)
    end

    def has_many_associate_ids(association_id)
      _t_get_associate_ids(association_id)
    end

    def set_has_many_associate_ids(association_id, associate_ids)
      clazz = associate_class(association_id)
      instance_variable_set ivar_name(association_id), clazz._t_find_bulk(associate_ids)
    end

    def save_without_callback
      @perform_save_associates_callback = false
      save
    ensure
      @perform_save_associates_callback = true
    end

    def has_many_property_name(association_id)
      self.class.has_many_property_name(association_id)
    end

    module ClassMethods #:nodoc:
      def initialize_has_many_association(association_id)
        _t_initialize_has_many_association(association_id) if self.respond_to?(:_t_initialize_has_many_association)

        attr_accessor "_t_" + association_id.to_s
        attr_accessor :perform_save_associates_callback
      end

      def _t_save_associates(record, association_id)
        return if record.perform_save_associates_callback == false

        _t_clear_old_associations(record, association_id)

        associates = (record.instance_variable_get "@_t_#{association_id.to_s}") || []
        associates.each do |associate|
          associate.send("#{property_name_for_record(record)}=", record.id)
          save_associate(associate)
        end

        unless associates.blank?
          associate_ids = associates.map { |associate| associate.id }
          record._t_associate_many(association_id, associate_ids)
          save_associate(record)
        end
      end

      def _t_clear_old_associations(record, association_id)
        clazz = associate_class(association_id)
        property_name = property_name_for_record(record)

        old_associates = clazz._t_find_all_by_associate(property_name, record.id)
        old_associates.each do |old_associate|
          old_associate.send("#{property_name}=", nil)
          save_associate(old_associate)
        end

        record._t_clear_associates(association_id)
        save_associate(record)
      end

      def property_name_for_record(record)
        "#{ActiveSupport::Inflector.underscore(record.class.to_s)}_id"
      end

      def has_many_property_name(association_id)
        "_t_" + ActiveSupport::Inflector.singularize(association_id) + "_ids"
      end

      def save_associate(associate)
        associate.respond_to?(:_t_save_without_callback) ? associate._t_save_without_callback : associate.save
      end
    end

  end
end

