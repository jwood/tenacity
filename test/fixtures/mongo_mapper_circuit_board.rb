class MongoMapperCircuitBoard
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :diagnosable, :polymorphic => true
end
