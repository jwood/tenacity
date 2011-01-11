class CouchRestDoor < CouchRest::ExtendedDocument
  include Tenacity
  use_database COUCH_DB

  property 'automobile_id'
  t_belongs_to :active_record_car, :foreign_key => 'automobile_id'
end

