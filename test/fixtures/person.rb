require 'mongo_mapper'
require 'tenacity'

class Person
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :account

  t_has_many :transactions
end
