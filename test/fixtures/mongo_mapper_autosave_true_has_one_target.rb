class MongoMapperAutosaveTrueHasOneTarget
  include MongoMapper::Document
  include Tenacity

  key :prop, String

  t_belongs_to :active_record_object, :autosave => true
end
