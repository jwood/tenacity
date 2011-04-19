def require_ripple
  begin
    require 'ripple'
    yield
  rescue LoadError
  end
end

begin
  require 'ripple'

  unless Ripple.client.ping
    puts "Riak is not running, and is required.  Please start it."
    exit
  end
rescue LoadError
  puts "WARNING:  Ripple could not be loaded.  Skipping tests."
end

