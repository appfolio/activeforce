require 'test_helper'

class Salesforce.connection::RestApiTest < ActiveSupport::TestCase
  def test_supported_objects
    connection.expects(:get).with("sobjects.json", :format => :json).returns({ "sobjects" => [ { "name" => "Account"}, { "name" => "Contact"}]})
    assert_equal [ "Account", "Contact" ], connection.supported_objects
  end
  
  def fields(object_name)
    raise ObjectNotSupported.new(object_name) unless supported_objects.include?(object_name)
    get("sobjects/#{object_name}/describe.json", :format => :json)["fields"]
  end
  
  def test_fields
    connection.expects(:supported_objects).returns(["Account"])
    connection.expects(:get).with("sobjects/Account/describe.json", :format => :json).returns("fields" => :fields)
    assert_equal :fields, connection.fields("Account")
  end

  def test_fields__fails
    connection.expects(:supported_objects).returns(["Account__c"])
    connection.expects(:get).never
    assert_raises Salesforce::ObjectNotSupported do
      connection.fields("Account")
    end
  end
  
  def test_find_object_by_id
    connection.expects(:get).with("sobjects/Bill__c/a123456789.json?fields=Account__c,Name,Due_Date__c", :format => :json).returns(:result)
    assert_equal :result, connection.find_object_by_id('Bill__c', 'a123456789', 'Account__c,Name,Due_Date__c' )
  end
  
  def test_update
    fields = { "Account__c" => 'a4000', 'Due_Date__c' => "08/10/2029"}
    connection.expects(:patch).with("sobjects/Bill__c/a123456789.json", fields.to_json, :format => :json).returns(stub(:code => 204))
    assert connection.update('Bill__c', 'a123456789', fields)
  end
  
  def test_create__succeeds
    fields = { "Account__c" => 'a4000', 'Due_Date__c' => "08/10/2029"}
    connection.expects(:post).with('sobjects/Bill__c.json', fields.to_json, :format => :json).returns({ "success" => true, "id" => "newid"})
    assert_equal "newid", connection.create('Bill__c', fields)
  end
  
  def test_create__fails
    fields = { "Account__c" => 'a4000', 'Due_Date__c' => "08/10/2029"}
    connection.expects(:post).with('sobjects/Bill__c.json', fields.to_json, :format => :json).returns({ "success" => false, "errors" => "something"})
    assert_raises Salesforce::RecordInvalid do 
      connection.create('Bill__c', fields)
    end
  end
  
  def test_delete
    connection.expects(:delete).with("sobjects/Bill__c/a123456789")
    connection.destroy("Bill__c", "a123456789")
  end
  
  def connection
    Salesforce.connection
  end
end