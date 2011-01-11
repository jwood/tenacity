class CouchRestWindshield < CouchRest::ExtendedDocument
  include Tenacity
  use_database COUCH_DB

  property :car_id
  t_belongs_to :active_record_car, :foreign_key => 'car_id'
end

