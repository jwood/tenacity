require 'mongo_mapper'

class MongoMapperLedger
  include MongoMapper::Document
  include Tenacity

  key :active_record_account_id, String

  t_has_one :active_record_auditor
end
