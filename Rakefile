require 'rubygems'
require 'bundler'

Bundler::GemHelper.install_tasks

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test' << 'test/fixtures'
  test.pattern = ENV['TEST_FILE'] ? ENV['TEST_FILE'] : "test/**/*_test.rb"
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test' << 'test/fixtures'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tenacity #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('EXTEND*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Delete rcov, rdoc, and other generated files'
task :clobber => [:clobber_rcov, :clobber_rdoc]

