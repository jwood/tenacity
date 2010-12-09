require 'mongo_mapper'

class MongoMapperPerson
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :active_record_account
  t_has_many :active_record_transactions
end
