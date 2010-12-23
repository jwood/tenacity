begin
  module CouchRest
    module Model
      class Base
        include CouchRest::TenacityInstanceMethods
        extend CouchRest::TenacityClassMethods
      end
    end
  end
rescue LoadError
  # CouchRest::Model not available
end
