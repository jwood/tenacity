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
  test.pattern = 'test/**/*_test.rb'
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

begin
  require 'test/helpers/active_record_test_helper'
  namespace :test do
    desc "Setup the test databases"
    task :prepare do
      system "mysqladmin -u root drop -f tenacity_test"
      system "mysqladmin -u root create tenacity_test"

      ActiveRecord::Schema.define :version => 0 do

        create_table :active_record_cars, :force => true do |t|
        end

        create_table :active_record_climate_control_units, :force => true do |t|
          t.string :mongo_mapper_dashboard_id
        end

        create_table :active_record_cars_mongo_mapper_wheels, :force => true do |t|
          t.integer :active_record_car_id
          t.string :mongo_mapper_wheel_id
        end

        create_table :active_record_nuts, :force => true do |t|
          t.string :mongo_mapper_wheel_id
        end

        create_table :active_record_nuts_mongo_mapper_wheels, :force => true do |t|
          t.integer :active_record_nut_id
          t.string :mongo_mapper_wheel_id
        end

      end
    end
  end
rescue LoadError
  # No ActiveRecord
end
