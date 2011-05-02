module Tenacity
  # Generic Tenacity exception class.
  class TenacityError < StandardError
  end

  # Raised on attempt to update an associate that is instantiated as read only.
  class ReadOnlyError < TenacityError
  end

  # Raised when one of the objects specified in the relationship does not exist in the database
  class ObjectDoesNotExistError < TenacityError
  end

  # Rasied when an attempt is made to delete an object whose id is in use by an association
  class ObjectIdInUseError < TenacityError
  end
end
