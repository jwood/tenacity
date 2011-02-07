module Tenacity
  # Generic Tenacity exception class.
  class TenacityError < StandardError
  end

  # Raised on attempt to update an associate that is instantiated as read only.
  class ReadOnlyError < TenacityError
  end
end
