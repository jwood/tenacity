class Transaction < ActiveRecord::Base
  include Tenacity
end
