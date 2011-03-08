module Tenacity
  module OrmExt
    module Helpers #:nodoc:

      def id_class_for(association)
        if association.type == :belongs_to
          association.source._t_id_type
        else
          association.associate_class._t_id_type
        end
      end

    end
  end
end
