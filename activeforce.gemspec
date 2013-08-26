# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "activeforce"
  s.version = "1.7.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tushar Ranka", "Andrew Mutz"]
  s.date = "2013-08-26"
  s.description = " Activeforce provides a simple to use and extend interface to Salesforce using the REST API"
  s.email = ["tusharranka@gmail.com", "andrew.mutz@appfolio.com"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "activeforce.gemspec",
    "app/models/salesforce/account.rb",
    "app/models/salesforce/activity_history.rb",
    "app/models/salesforce/approval.rb",
    "app/models/salesforce/campaign.rb",
    "app/models/salesforce/campaign_feed.rb",
    "app/models/salesforce/campaign_member.rb",
    "app/models/salesforce/case.rb",
    "app/models/salesforce/case_comment.rb",
    "app/models/salesforce/case_contact_role.rb",
    "app/models/salesforce/case_feed.rb",
    "app/models/salesforce/case_history.rb",
    "app/models/salesforce/case_share.rb",
    "app/models/salesforce/case_solution.rb",
    "app/models/salesforce/case_status.rb",
    "app/models/salesforce/case_team_member.rb",
    "app/models/salesforce/community.rb",
    "app/models/salesforce/contact.rb",
    "app/models/salesforce/contact_feed.rb",
    "app/models/salesforce/contact_history.rb",
    "app/models/salesforce/contract.rb",
    "app/models/salesforce/document.rb",
    "app/models/salesforce/event.rb",
    "app/models/salesforce/feed_item.rb",
    "app/models/salesforce/group.rb",
    "app/models/salesforce/group_member.rb",
    "app/models/salesforce/idea.rb",
    "app/models/salesforce/lead.rb",
    "app/models/salesforce/lead_status.rb",
    "app/models/salesforce/name.rb",
    "app/models/salesforce/note.rb",
    "app/models/salesforce/open_activity.rb",
    "app/models/salesforce/opportunity.rb",
    "app/models/salesforce/organization.rb",
    "app/models/salesforce/partner.rb",
    "app/models/salesforce/period.rb",
    "app/models/salesforce/product2.rb",
    "app/models/salesforce/product2_feed.rb",
    "app/models/salesforce/profile.rb",
    "app/models/salesforce/quote.rb",
    "app/models/salesforce/solution.rb",
    "app/models/salesforce/task.rb",
    "app/models/salesforce/task_feed.rb",
    "app/models/salesforce/task_priority.rb",
    "app/models/salesforce/task_status.rb",
    "app/models/salesforce/user.rb",
    "app/models/salesforce/user_role.rb",
    "app/models/salesforce/vote.rb",
    "lib/activeforce.rb",
    "lib/salesforce/attributes.rb",
    "lib/salesforce/authentication.rb",
    "lib/salesforce/base.rb",
    "lib/salesforce/bulk/batch.rb",
    "lib/salesforce/bulk/job.rb",
    "lib/salesforce/bulk/operations.rb",
    "lib/salesforce/bulk/update_job.rb",
    "lib/salesforce/column.rb",
    "lib/salesforce/columns.rb",
    "lib/salesforce/config.rb",
    "lib/salesforce/connection.rb",
    "lib/salesforce/connection/async.rb",
    "lib/salesforce/connection/conversion.rb",
    "lib/salesforce/connection/http_methods.rb",
    "lib/salesforce/connection/rest_api.rb",
    "lib/salesforce/connection/soap_api.rb",
    "lib/salesforce/engine.rb",
    "lib/salesforce/errors.rb",
    "test/salesforce/authentication_test.rb",
    "test/salesforce/base_test.rb",
    "test/salesforce/bulk/batch_test.rb",
    "test/salesforce/bulk/update_job_test.rb",
    "test/salesforce/column_test.rb",
    "test/salesforce/config_test.rb",
    "test/salesforce/connection/async_test.rb",
    "test/salesforce/connection/http_methods_test.rb",
    "test/salesforce/connection/rest_api_test.rb",
    "test/salesforce/connection/soap_api_test.rb",
    "test/salesforce/connection_test.rb",
    "test/test_helper.rb"
  ]
  s.homepage = "http://github.com/appfolio/activeforce"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "A Simple gem to interact with the Salesforce REST API"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, [">= 0"])
      s.add_runtime_dependency(%q<savon>, ["~> 1.0"])
      s.add_runtime_dependency(%q<blockenspiel>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<fastercsv>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<rails>, [">= 0"])
      s.add_dependency(%q<savon>, ["~> 1.0"])
      s.add_dependency(%q<blockenspiel>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<fastercsv>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, [">= 0"])
    s.add_dependency(%q<savon>, ["~> 1.0"])
    s.add_dependency(%q<blockenspiel>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<fastercsv>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<yard>, ["~> 0.6.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

