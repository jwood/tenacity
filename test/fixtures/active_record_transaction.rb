class ActiveRecordTransaction < ActiveRecord::Base
  include Tenacity
end
