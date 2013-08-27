# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "activeforce"
  gem.homepage = "http://github.com/appfolio/activeforce"
  gem.license = "MIT"
  gem.summary = %Q{A Simple gem to interact with the Salesforce REST API}
  gem.description = %Q{ Activeforce provides a simple to use and extend interface to Salesforce using the REST API}
  gem.email = ["tusharranka@gmail.com", "andrew.mutz@appfolio.com"]
  gem.authors = ["Tushar Ranka", "Andrew Mutz"]
end

Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

require 'yard'
YARD::Rake::YardocTask.new
