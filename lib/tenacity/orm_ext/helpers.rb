module Tenacity
  module OrmExt
    module Helpers #:nodoc:

      def id_class_for(association)
        if association.polymorphic?
          String
        elsif association.type == :belongs_to
          association.source._t_id_type
        else
          association.associate_class._t_id_type
        end
      end

      def _t_serialize_ids(ids, association=nil)
        if ids.respond_to?(:map)
          ids.map { |id| _t_serialize(id, association) }
        else
          _t_serialize(ids, association)
        end
      end

      def _t_serialize_id_for_sql(id)
        return id if id.nil?

        serialized_id = _t_serialize(id)
        if serialized_id.class == String
          "'#{serialized_id}'"
        else
          serialized_id
        end
      end

    end
  end
end
