# -*- encoding: utf-8 -*-
require File.expand_path("../lib/tenacity/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "tenacity"
  s.license     = "MIT"
  s.version     = Tenacity::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Wood"]
  s.email       = ["john@johnpwood.net"]
  s.homepage    = "http://github.com/jwood/tenacity"
  s.summary     = %Q{A database client independent way of specifying simple relationships between models backed by different databases.}
  s.description = %Q{Tenacity provides a database client independent way of specifying simple relationships between models backed by different databases.}

  s.rubyforge_project = "tenacity"

  s.required_rubygems_version = ">= 1.3.6"

  s.add_runtime_dependency "activesupport", "~> 2.3"

  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "rake", "~> 0.8.7"
  s.add_development_dependency "rcov", "~> 0.9.9"
  s.add_development_dependency "shoulda", "~> 2.11.3"
  s.add_development_dependency "mocha", "~> 0.9.10"
  s.add_development_dependency "yard", "~> 0.6.4"

  # Relational DBs
  s.add_development_dependency "sqlite3-ruby", "~> 1.3.1"
  s.add_development_dependency "activerecord", "~> 2.3"
  s.add_development_dependency "datamapper", "~> 1.0.2"
  s.add_development_dependency "dm-sqlite-adapter", "~> 1.0.2"
  s.add_development_dependency "sequel", "~> 3.19.0"

  # MongoDB
  s.add_development_dependency "mongo_mapper", "~> 0.8.6"
  s.add_development_dependency "bson_ext", "~> 1.2.4"

  # CouchDB
  s.add_development_dependency "couchrest", "~> 1.0.0"
  s.add_development_dependency "couchrest_extended_document", "~> 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

