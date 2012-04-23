class ActiveRecordOrganization < ActiveRecord::Base
  include Tenacity
  
  has_many :active_record_users
end