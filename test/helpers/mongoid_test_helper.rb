def require_mongoid
  begin
    require 'mongoid'
    yield
  rescue LoadError
  end
end

begin
  require 'mongoid'

  Mongoid.configure do |config|
    name = "tenacity_test"
    host = "localhost"
    config.master = Mongo::Connection.new.db(name)
    config.persist_in_safe_mode = false
  end
rescue LoadError
  puts "WARNING:  Mongoid could not be loaded.  Skipping tests."
end

