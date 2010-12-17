class ActiveRecordAuditor < ActiveRecord::Base
  include Tenacity
end
