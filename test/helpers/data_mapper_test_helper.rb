require 'datamapper'
require 'dm-migrations'
require 'dm-migrations/migration_runner'

DataMapper.setup(:default, {
  :adapter  => 'sqlite3',
  :database => ':memory:'})  

migrate_up!

def migrate_data_mapper_tables
  DataMapperHasManyTarget
  DataMapperHasOneTarget
  DataMapperObject

  DataMapper.auto_migrate!
end

