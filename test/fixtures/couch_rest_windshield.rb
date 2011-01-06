require 'couchrest_model'

class CouchRestWindshield < CouchRest::Model::Base
  include Tenacity
  use_database COUCH_DB

  property :car_id
  t_belongs_to :active_record_car, :foreign_key => 'car_id'
end

