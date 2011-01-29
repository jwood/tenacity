class MongoMapperAirFilter
  include MongoMapper::Document
  include Tenacity

  t_belongs_to :active_record_engine, :dependent => :destroy
end
