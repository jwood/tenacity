require 'mongo_mapper'

class MongoMapperPerson
  include MongoMapper::Document
  include Tenacity

  key :active_record_account_id, Integer
  t_belongs_to :active_record_account

  key :active_record_transaction_ids, Array
  t_has_many :active_record_transactions
end
