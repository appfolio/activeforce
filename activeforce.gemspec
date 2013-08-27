# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'activeforce/version'

Gem::Specification.new do |s|
  s.name = "activeforce"
  s.version = Activeforce::VERSION

  s.authors          = ["Tushar Ranka", "Andrew Mutz"]
  s.date             = "2013-08-27"
  s.description      = " Activeforce provides a simple to use and extend interface to Salesforce using the REST API"
  s.email            = ["tusharranka@gmail.com", "andrew.mutz@appfolio.com"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files            = `git ls-files`.split("\n")
  s.homepage         = "http://github.com/appfolio/activeforce"
  s.licenses         = ["MIT"]
  s.require_paths    = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary          = "A Simple gem to interact with the Salesforce REST API"

  s.add_dependency(%q<rails>, [">= 3.0"])
  s.add_dependency(%q<savon>, ["~> 1.0"])
  s.add_dependency(%q<blockenspiel>, [">= 0"])
  s.add_dependency(%q<rest-client>, [">= 0"])
  s.add_dependency(%q<fastercsv>, [">= 0"])
end

