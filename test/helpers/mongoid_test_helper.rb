def require_mongoid
  begin
    require 'mongoid'
    yield
  rescue LoadError
  end
end

begin
  require 'mongoid'
  Mongoid.load!(File.expand_path("../../../config/mongoid.yml", __FILE__), :test)
rescue LoadError
  puts "WARNING:  Mongoid could not be loaded.  Skipping tests."
end

