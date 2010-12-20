class MongoMapperButton
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :couch_rest_radio
end
