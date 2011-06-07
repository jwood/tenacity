def require_toystore
  begin
    require 'toystore'
    yield
  rescue LoadError
  end
end

begin
  require 'toystore'

  FileUtils.mkdir_p("log")
  Toy.logger = ::Logger.new(File.join("log", "toystore.log"))
rescue LoadError
  puts "WARNING:  Toystore could not be loaded.  Skipping tests."
end

