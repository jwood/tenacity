module Tenacity
  module Associations
    module HasMany #:nodoc:

      def _t_remove_associates(association)
        instance_variable_set(_t_ivar_name(association), [])
      end

      def _t_cleanup_has_many_association(association)
        associates = has_many_associates(association)
        unless associates.nil? || associates.empty?
          if association.dependent == :destroy
            delete_or_destroy_has_many_associates(association, associates)
          elsif association.dependent == :delete_all
            delete_or_destroy_has_many_associates(association, associates, false)
          elsif association.dependent == :nullify
            nullify_foreign_keys_for_has_many_associates(association, associates)
          elsif association.foreign_key_constraints_enabled?
            raise ObjectIdInUseError.new("Unable to delete #{self.class} with id of #{self.id} because its id is being referenced by instances of #{associates.first.class}(id: #{associates.map(&:id).join(',')})!")
          end
        end
      end

      def _t_get_associate_ids(association)
        if self.id.nil?
          []
        else
          foreign_key = association.foreign_key(self.class)
          associate_id = self.class._t_serialize_ids(self.id, association)
          ids = association.associate_class._t_find_all_ids_by_associate(foreign_key, associate_id)
          self.class._t_serialize_ids(ids, association)
        end
      end

      private

      def has_many_associates(association)
        ids = _t_get_associate_ids(association)
        pruned_ids = prune_associate_ids(association, ids)
        clazz = association.associate_class
        clazz._t_find_bulk(pruned_ids)
      end

      def set_has_many_associates(association, associates)
        associates.map { |associate| AssociateProxy.new(associate, association) }
      end

      def has_many_associate_ids(association)
        ids = _t_get_associate_ids(association)
        prune_associate_ids(association, ids)
      end

      def set_has_many_associate_ids(association, associate_ids)
        clazz = association.associate_class
        instance_variable_set(_t_ivar_name(association), clazz._t_find_bulk(associate_ids))
      end

      def save_without_callback
        @perform_save_associates_callback = false
        _t_save_if_dirty
      ensure
        @perform_save_associates_callback = true
      end

      def prune_associate_ids(association, associate_ids)
        if association.limit || association.offset
          sorted_ids = associate_ids.sort { |a,b| a <=> b }

          limit = association.limit || associate_ids.size
          offset = association.offset || 0
          sorted_ids[offset...(offset + limit)]
        else
          associate_ids
        end
      end

      def delete_or_destroy_has_many_associates(association, associates, run_callbacks=true)
        associates.each { |associate| association.associate_class._t_delete(_t_serialize(associate.id), run_callbacks) }
      end

      def nullify_foreign_keys_for_has_many_associates(association, associates)
        associates.each do |associate|
          associate.send "#{association.foreign_key(self.class)}=", nil
          associate._t_save_if_dirty
        end
      end

      module ClassMethods #:nodoc:
        def initialize_has_many_association(association)
          _t_initialize_has_many_association(association) if self.respond_to?(:_t_initialize_has_many_association)

          attr_accessor :perform_save_associates_callback
        end

        def _t_save_associates(record, association)
          return if record.perform_save_associates_callback == false

          loaded_associations = record.instance_variable_get('@_t_loaded_associations')
          if record.instance_variable_get(record._t_ivar_name(association)).nil? &&
              (loaded_associations.nil? || loaded_associations[association].nil?)
            return
          end

          old_associates = get_current_associates(record, association)

          # Some ORM libraries (CouchRest, ActiveRecord, etc) return a proxy in
          # place of the associated objects.  The actual associated objects
          # will be fetched the first time they are needed.  So, force them to
          # be fetched here, before we clear them out in the database.
          old_associates.first

          _t_clear_old_associations(record, association, old_associates)

          associates = (record.instance_variable_get(record._t_ivar_name(association))) || []
          establish_relationship_in_target_objects(record, association, associates)
          destroy_orphaned_associates(association, old_associates, associates)
        end

        def _t_clear_old_associations(record, association, old_associates)
          property_name = association.foreign_key(record.class)
          old_associates.each do |old_associate|
            old_associate.send("#{property_name}=", nil)
            save_associate(old_associate)
          end
        end

        def save_associate(associate)
          associate.respond_to?(:_t_save_without_callback) ? associate._t_save_without_callback : associate._t_save_if_dirty
        end

        def get_current_associates(record, association)
          clazz = association.associate_class
          property_name = association.foreign_key(record.class)
          clazz._t_find_all_by_associate(property_name, _t_serialize(record.id, association))
        end

        def destroy_orphaned_associates(association, old_associates, associates)
          if association.dependent == :destroy || association.dependent == :delete_all
            issue_callbacks = (association.dependent == :destroy)
            (old_associates.map{|a| a.id} - associates.map{|a| a.id}).each do |associate_id|
              association.associate_class._t_delete([_t_serialize(associate_id)], issue_callbacks)
            end
          end
        end

        def establish_relationship_in_target_objects(record, association, associates)
          associates.each do |a|
            associate = a._t_reload
            associate.send("#{association.foreign_key(record.class)}=", _t_serialize(record.id, association))
            associate.send "#{association.polymorphic_type}=", self.to_s if association.polymorphic?
            save_associate(associate)
          end
        end
      end

    end
  end
end

