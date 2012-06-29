require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'activeforce'
Dir.glob(File.expand_path('../../app/models/salesforce/**.rb', __FILE__)).each { |file| require(file) }

class Test::Unit::TestCase
end

Time.zone = 'America/Los_Angeles'

class ActiveSupport::TestCase
  setup :clean_configuration
  setup :stub_soap
  
  class ::Salesforce::BulkTable < Salesforce::Base
    self.custom_object = true
  end

  def clean_configuration
    Salesforce::Config.instance_variable_set(:@instance, nil)
  end
  
  def stub_soap
    Savon::Client.any_instance.stubs(:request)
  end
  
  def clear_columns_for_bulk_table
    Salesforce::BulkTable.cached_columns   = nil
  end
  
  def clear_columns_for_account
    Salesforce::Account.cached_columns   = nil
  end
  
  def setup_columns_for_bulk_table
    clear_columns_for_bulk_table
    columns_hash = [ 
      { "name" => "Id", "type" => "id", "createable" => false, "updateable" => false}, 
      { "name" => "Account__c", "type" => "reference", "createable" => true, "updateable" => false, "custom" => true }, 
      { "name" => "Car__c", "type" => "reference", "createable" => false, "updateable" => true, "custom" => true},
      { "name" => "Name__c", "type" => "string", "createable" => true, "updateable" => true, "custom" => true},
      { "name" => "dob__c", "type" => "date", "createable" => true, "updateable" => true, "custom" => true} 
    ]
    
    Salesforce.connection.stubs(:fields).with("BulkTable__c").returns(columns_hash).twice
    columns      = Salesforce::Columns.new("BulkTable__c")
    assert_equal columns, Salesforce::BulkTable.columns
  end
  
  def setup_columns_for_account
    clear_columns_for_account
    columns_hash = [ 
      { "name" => "Id", "type" => "id", "createable" => false, "updateable" => false}, 
      { "name" => "Name", "type" => "string", "createable" => true, "updateable" => true}, 
      { "name" => "Type", "type" => "string", "createable" => true, "updateable" => true}, 
      { "name" => "Address", "type" => "string", "createable" => true, "updateable" => true}, 
      { "name" => "City", "type" => "string", "createable" => true, "updateable" => true}, 
      { "name" => "State", "type" => "string", "createable" => true, "updateable" => true},
      { "name" => "Number", "type" => "string", "createable" => true, "updateable" => false}
    ]
    
    Salesforce.connection.stubs(:fields).with("Account").returns(columns_hash).twice
    columns      = Salesforce::Columns.new("Account")
    assert_equal columns, Salesforce::Account.columns
  end
  
  
end
