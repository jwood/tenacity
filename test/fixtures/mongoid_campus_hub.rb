class MongoidCampusHub
  include Mongoid::Document
  include Mongoid::Timestamps
  include Tenacity
  
  t_belongs_to :active_record_organization
end
