module Tenacity
  module OrmExt
    module Ripple

      def self.setup(model) #:nodoc:
        require 'ripple'
        if model.included_modules.include?(::Ripple::Document)
          model.send :include, Ripple::InstanceMethods
          model.extend Ripple::ClassMethods
        end
      rescue LoadError
        # Ripple not available
      end

      module ClassMethods #:nodoc:
        include Tenacity::OrmExt::Helpers

        def _t_id_type
          String
        end

        def _t_find(key)
          find(_t_serialize(key))
        end
      end

      module InstanceMethods #:nodoc:
      end

    end
  end
end


