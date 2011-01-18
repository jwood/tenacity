module Tenacity
  module Sequel

    def self.setup(model)
      require 'sequel'
      if model.superclass == ::Sequel::Model
        model.send :include, Sequel::InstanceMethods
        model.extend Sequel::ClassMethods
      end
    rescue LoadError
      # Sequel not available
    end

    module ClassMethods #:nodoc:
      def _t_find(id)
        self[id]
      end

      def _t_find_bulk(ids)
        return [] if ids.nil? || ids.empty?
        filter(:id => ids)
      end

      def _t_find_first_by_associate(property, id)
        first(property => id.to_s)
      end

      def _t_find_all_by_associate(property, id)
        filter(property => id)
      end

      def _t_initialize_has_many_association(association)
      end

      def _t_initialize_belongs_to_association(association)
      end

      def _t_delete(ids, run_callbacks=true)
        if run_callbacks
          filter(:id => ids).destroy
        else
          filter(:id => ids).delete
        end
      end
    end

    module InstanceMethods #:nodoc:
      def _t_reload
        reload
      end

      def _t_clear_associates(association)
        db["delete from #{association.join_table} where #{association.association_key} = #{self.id}"].delete
      end

      def _t_associate_many(association, associate_ids)
        db.transaction do
          _t_clear_associates(association)
          associate_ids.each do |associate_id|
            db["insert into #{association.join_table} (#{association.association_key}, #{association.association_foreign_key}) values (#{self.id}, '#{associate_id}')"].insert
          end
        end
      end

      def _t_get_associate_ids(association)
        return [] if self.id.nil?
        rows = db["select #{association.association_foreign_key} from #{association.join_table} where #{association.association_key} = #{self.id}"].all
        rows.map { |row| row[association.association_foreign_key.to_sym] }
      end
    end

  end
end
