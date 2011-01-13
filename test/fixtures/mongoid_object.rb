require_mongoid do
  class MongoidObject
    include Mongoid::Document
    include Tenacity

    t_has_one :active_record_has_one_target
    t_has_one :couch_rest_has_one_target
    t_has_one :mongo_mapper_has_one_target
    t_has_one :mongoid_has_one_target

    t_has_many :active_record_has_many_targets
    t_has_many :couch_rest_has_many_targets
    t_has_many :mongo_mapper_has_many_targets
    t_has_many :mongoid_has_many_targets
  end
end
