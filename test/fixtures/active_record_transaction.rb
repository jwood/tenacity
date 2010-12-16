class ActiveRecordTransaction < ActiveRecord::Base
  include Tenacity

  t_belongs_to :mongo_mapper_ledger
end
