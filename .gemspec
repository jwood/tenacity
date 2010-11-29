# coding: utf-8
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'tenacity'
 
spec = Gem::Specification.new do |s|
  s.name = s.rubyforge_project = 'tenacity'
  s.version = Tenacity::VERSION
 
  s.author = 'John Wood'
  s.description = 'A ORM independent way of specifying simple relationships between models.'
  s.email = 'john@johnpwood.net'
  s.homepage = 'http://github.com/jwood/tenacity'
  s.summary = 'Tenacity provides an ORM independent way of specifying simple relationships between models backed by different databases.'
 
  s.has_rdoc = true
  s.rdoc_options = ['-a', '--inline-source', '--charset=UTF-8']
 
  s.files = Dir.glob('lib/*.rb') + %w(README.rdoc)
  s.test_files = Dir.glob('test/test_*.rb')
 
  s.executables = Dir.glob('lib/*')
end

