class MongoidAlternator
  include Mongoid::Document
  include Tenacity

  t_belongs_to :active_record_engine
  t_has_many :mongo_mapper_coils
end
