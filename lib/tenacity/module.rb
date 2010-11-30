require 'active_support/inflector'

module Tenacity
  def self.included(model)
    model.extend(ClassMethods)
  end 

  module ClassMethods
    def t_belongs_to(associate, args={})
      send :define_method, associate do
      end

      send :define_method, "#{associate}=" do
      end

      send :define_method, "#{associate}_id" do
      end
    end

    def t_has_many(associate, args={})
      send :define_method, associate do
      end

      send :define_method, "#{associate}=" do
      end

      send :define_method, "#{ActiveSupport::Inflector.singularize(associate.to_s)}_ids" do
      end
    end
  end

end
