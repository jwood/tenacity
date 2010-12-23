module CouchRest
  class ExtendedDocument #:nodoc:
    include CouchRest::TenacityInstanceMethods
    extend CouchRest::TenacityClassMethods
  end
end

