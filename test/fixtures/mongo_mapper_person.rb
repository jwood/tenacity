require 'mongo_mapper'

class MongoMapperPerson
  include MongoMapper::Document
  include Tenacity

  # TODO: Find a way to dynamically create
  key :active_record_account_id, Integer
  t_belongs_to :active_record_account

  # TODO: Find a way to dynamically create
  key :_t_active_record_transaction_ids, Array
  t_has_many :active_record_transactions
end
