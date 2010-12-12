class TenacityLogger
  def self.log(source, message)
    puts "#{source}: #{message}" if ENV['TENACITY_DEBUG'] == 'true'
  end
end
