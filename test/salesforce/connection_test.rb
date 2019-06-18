require 'test_helper'

class Salesforce::ConnectionTest < ActiveSupport::TestCase
  def test_query__less_than_2000_records
    Salesforce.connection.expects(:get).with("query.json?q=SELECT+Id+FROM+Account", :format => :json).returns({ "records" => [{ :record => 1, "attributes" => 'foo'}], "done" => true, "totalSize" => 1999})
    assert_equal [{ :record => 1 }], Salesforce.connection.soql("SELECT Id FROM Account")
  end

  def test_query__more_than_2000_records
    Salesforce.connection.expects(:get).with("query.json?q=SELECT+Id+FROM+Account", :format => :json).returns({
      "records" => [ { :record => 1, "attributes" => "foo" } ], "done" => false, "totalSize" => 4999, "nextRecordsUrl" =>"/services/data/v22.0/query/01g8000000L9FSmAAN-2000"})

    Salesforce.connection.expects(:get).with("/services/data/v22.0/query/01g8000000L9FSmAAN-2000.json", :format => :json).returns({
      "records" => [ { :record => 2, "attributes" => "foo" } ], "done" => false, "totalSize" => 4999, "nextRecordsUrl" =>"/services/data/v22.0/query/01g8000000L9FSmAAN-4000"})

    Salesforce.connection.expects(:get).with("/services/data/v22.0/query/01g8000000L9FSmAAN-4000.json", :format => :json).returns({
      "records" => [ { :record => 3, "attributes" => "foo" } ], "done" => true, "totalSize" => 4999})

    assert_equal [{ :record => 1}, { :record => 2}, { :record => 3}], Salesforce.connection.soql("SELECT Id FROM Account")
  end

  def test_as_logged_in_user__login_succeeded__calls_block
    Salesforce::Authentication.expects(:session_id)
    results = Salesforce.connection.as_logged_in_user do
      :results
    end
    assert_equal :results, results
  end

  def test_as_logged_in_user__logged_out__recovers
    flag = nil
    Salesforce::Authentication.expects(:session_id).twice
    Salesforce::Authentication.expects(:logout)
    error = RestClient::Unauthorized.new
    results = Salesforce.connection.as_logged_in_user do
      unless flag
        flag = true
        raise error
      end
      :results
    end
    assert_equal :results, results
  end

  def test_as_logged_in_user__authorization_failure
    flag = nil
    Salesforce::Authentication.expects(:session_id).times(2)
    Salesforce::Authentication.expects(:logout)
    error = RestClient::Unauthorized.new
    assert_raises RestClient::Unauthorized do
      Salesforce.connection.as_logged_in_user do
        raise error
      end
    end
  end

  def test_as_logged_in_user__invalid_username_password__recovers
    on_login_failure_called = false

    Salesforce.configure do
      on_login_failure { on_login_failure_called = true }
    end

    xml = <<-XML
    <?xml version='1.0' encoding='UTF-8'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><soapenv:Fault xmlns:fns="http://fault.api.zuora.com/"><faultcode>sf:INVALID_LOGIN</faultcode><faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring><detail><fns:LoginFault><fns:FaultCode>INVALID_LOGIN</fns:FaultCode><fns:FaultMessage>Invalid username, password, security token; or user locked out.</fns:FaultMessage></fns:LoginFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>
    XML

    error = Savon::SOAP::Fault.new(stub(:body => xml))

    flag = nil
    Salesforce::Authentication.expects(:session_id).twice
    Salesforce::Authentication.expects(:logout)
    results = Salesforce.connection.as_logged_in_user do
      unless flag
        flag = true
        raise error
      end
      :results
    end

    assert_equal :results, results
    assert on_login_failure_called, "Salesforce::Config.on_login_failure was not called upon login failure"
  end

  def test_as_logged_in_user__invalid_username_password__doesnt_recover
    on_login_failure_called = 0

    Salesforce.configure do
      on_login_failure { on_login_failure_called += 1 }
    end

    xml = <<-XML
    <?xml version='1.0' encoding='UTF-8'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><soapenv:Fault xmlns:fns="http://fault.api.zuora.com/"><faultcode>sf:INVALID_LOGIN</faultcode><faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring><detail><fns:LoginFault><fns:FaultCode>INVALID_LOGIN</fns:FaultCode><fns:FaultMessage>Invalid username, password, security token; or user locked out.</fns:FaultMessage></fns:LoginFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>
    XML

    error = Savon::SOAP::Fault.new(stub(:body => xml))

    flag = nil
    Salesforce::Authentication.expects(:session_id).twice
    Salesforce::Authentication.expects(:logout)

    assert_raises Savon::SOAP::Fault do
      Salesforce.connection.as_logged_in_user do
        raise error
      end
    end

    assert_equal 1, on_login_failure_called, "Salesforce::Config.on_login_failure was not called upon login failure"
  end

  def test_as_logged_in_user__invalid_username_password__recovers__no_on_login_failure_hook
    xml = <<-XML
    <?xml version='1.0' encoding='UTF-8'?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><soapenv:Fault xmlns:fns="http://fault.api.zuora.com/"><faultcode>sf:INVALID_LOGIN</faultcode><faultstring>INVALID_LOGIN: Invalid username, password, security token; or user locked out.</faultstring><detail><fns:LoginFault><fns:FaultCode>INVALID_LOGIN</fns:FaultCode><fns:FaultMessage>Invalid username, password, security token; or user locked out.</fns:FaultMessage></fns:LoginFault></detail></soapenv:Fault></soapenv:Body></soapenv:Envelope>
    XML

    error = Savon::SOAP::Fault.new(stub(:body => xml))

    flag = nil
    Salesforce::Authentication.expects(:session_id).twice
    Salesforce::Authentication.expects(:logout)
    results = Salesforce.connection.as_logged_in_user do
      unless flag
        flag = true
        raise error
      end
      :results
    end

    assert_equal :results, results
  end

  def test_as_logged_in_user__other_failure
    Salesforce::Authentication.stubs(:session_id)
    Salesforce::Authentication.stubs(:logout)

    expects(:my_method).twice.raises(RestClient::Unauthorized.new).then.raises(StandardError.new("some other error"))

    assert_raises StandardError do
      Salesforce.connection.as_logged_in_user do
        my_method
      end
    end
  end

  def test_convert
    assert_equal "str", Salesforce.connection.convert("str", {})
  end
end