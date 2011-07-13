class DataMapperObjectWithStringId
  include DataMapper::Resource
  include Tenacity

  property :id, String, :key => true
end
