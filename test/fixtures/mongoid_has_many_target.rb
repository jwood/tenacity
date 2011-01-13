require_mongoid do
  class MongoidHasManyTarget
    include Mongoid::Document
    include Tenacity

    t_belongs_to :active_record_object
    t_belongs_to :couch_rest_object
    t_belongs_to :mongo_mapper_object
    t_belongs_to :mongoid_object
  end
end
