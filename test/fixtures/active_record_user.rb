class ActiveRecordUser < ActiveRecord::Base
  include Tenacity
  
  belongs_to :active_record_organization, :autosave => true
end