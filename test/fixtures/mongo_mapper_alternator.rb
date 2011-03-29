class MongoMapperAlternator
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :active_record_engine, :dependent => :delete
  t_has_one :mongo_mapper_circuit_board, :as => :diagnosable
end
