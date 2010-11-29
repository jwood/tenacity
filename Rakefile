require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

spec = eval(File.new(".gemspec").readlines.join("\n"))

task :default => :test

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

Rake::RDocTask.new(:rdoc) do |rd|
  rd.rdoc_files.include("lib/**/*.rb", "README.rdoc")
  rd.options + ['-a', '--inline-source', '--charset=UTF-8']
end

Rake::TestTask.new(:test) do |t| 
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.libs << 'test'
end

