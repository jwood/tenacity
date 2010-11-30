module Tenacity

  def self.included(model)
    model.extend(ClassMethods)
  end 

  module ClassMethods
    def t_belongs_to(args)
    end

    def t_has_many(args)
    end
  end

end
