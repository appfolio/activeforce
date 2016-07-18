require 'test_helper'

class Salesforce::Connection::SoapApiTest < ActiveSupport::TestCase

  def test_login
    expected_options = { 
      :endpoint_url => :soap_login_url,
      :body         => { 
        :username => :soap_username, 
        :password => :soap_password, 
        :order!   => [ :username, :password ] 
      } 
    }
    
    Salesforce::Config.expects(:login_url).returns(:soap_login_url)
    Salesforce::Config.expects(:username).returns(:soap_username)
    Salesforce::Config.expects(:password).returns(:soap_password)
    
    Salesforce.connection.expects(:invoke_soap).with(:login, expected_options).returns(:login_result)
    
    assert_equal :login_result, Salesforce.connection.login
  end
  
  def test_convert_lead
    expected_options = { 
      :body         => { 
        :leadConverts => :some_lead_converts
      } 
    }

    Salesforce.connection.expects(:as_logged_in_user).yields.returns(:convert_lead_result)
    Salesforce.connection.expects(:invoke_soap).with(:convertLead, expected_options)
    
    assert_equal :convert_lead_result, Salesforce.connection.convert_lead(:some_lead_converts)
  end

  def test_invoke_soap__not_login__success
    options = {
      :endpoint_url => Salesforce::Config.login_url,
      :body => :soap_body,
      :other_option => 'foo'
    }

    result = {
      :not_login_response => {
        :result => {
          :stuff => "i like",
          :success => true
        }
      }
    }
    
    expected_result = result[:not_login_response][:result]

    # stub savon
    stub_response = stub(:http => stub(:code => 200, :headers => {}, :cookies => []), :body => result)
    stub_response.stubs(:kind_of?).returns(true)

    Savon::Operation.any_instance.stubs(:create_response).returns(stub_response)

    HTTPI.stubs(:post).with do |request, _|
      assert_includes request.body, "xmlns:ns1=\"soap:enterprise:namespace\""
      xml_doc = Nokogiri::XML(request.body)
      assert_equal 'soap_body', xml_doc.xpath('//wsdl:notLogin/text()').to_s
      assert_equal 'boyahh_session_id', xml_doc.xpath('//env:Header/ns1:SessionHeader/ns1:sessionId/text()').to_s
      assert_equal '"notLogin"', request.headers['SOAPAction']
      assert_equal Salesforce::Config.login_url, request.url.to_s
    end.returns(stub_response)

    Salesforce::Config.stubs(:session_id).returns('boyahh_session_id')
    Salesforce::Config.stubs(:soap_enterprise_namespace).returns('soap:enterprise:namespace')
    
    assert_equal expected_result, Salesforce.connection.send(:invoke_soap, :notLogin, options)    
  end

  def test_invoke_soap__not_login__not_success
    options = {
      :endpoint_url => Salesforce::Config.login_url,
      :body => :soap_body,
      :other_option => 'foo'
    }

    result = {
      :not_login_response => {
        :result => {
          :errors => { :inspect => :me },
          :success => false
        }
      }
    }

    # stub savon
    stub_response = stub(:http => stub(:code => 200, :headers => {}, :cookies => []), :body => result)
    stub_response.stubs(:kind_of?).returns(true)

    Savon::Operation.any_instance.stubs(:create_response).returns(stub_response)

    HTTPI.stubs(:post).with do |request, _|
      assert_includes request.body, "xmlns:ns1=\"soap:enterprise:namespace\""
      xml_doc = Nokogiri::XML(request.body)
      assert_equal 'soap_body', xml_doc.xpath('//wsdl:notLogin/text()').to_s
      assert_equal 'boyahh_session_id', xml_doc.xpath('//env:Header/ns1:SessionHeader/ns1:sessionId/text()').to_s
      assert_equal '"notLogin"', request.headers['SOAPAction']
      assert_equal Salesforce::Config.login_url, request.url.to_s
    end.returns(stub_response)

    Salesforce::Config.stubs(:session_id).returns('boyahh_session_id')
    Salesforce::Config.stubs(:soap_enterprise_namespace).returns('soap:enterprise:namespace')
    
    assert_raises Salesforce::Connection::SoapApi::Error do
      Salesforce.connection.send(:invoke_soap, :notLogin, options)
    end
  end

  def test_invoke_soap__login
    options = {
      :endpoint_url => Salesforce::Config.login_url,
      :body => :soap_body,
      :other_option => 'foo'
    }

    result = {
      :login_response => {
        :result => {
          :stuff => "i like"
        }
      }
    }
    
    expected_result = result[:login_response][:result]

    stub_response = stub(:http => stub(:code => 200, :headers => {}, :cookies => []), :body => result)
    stub_response.stubs(:kind_of?).returns(true)

    Savon::Operation.any_instance.stubs(:create_response).returns(stub_response)

    HTTPI.stubs(:post).with do |request, _|
      xml_doc = Nokogiri::XML(request.body)
      assert_equal 'soap_body', xml_doc.xpath('//wsdl:login/text()').to_s
      assert_equal '"login"', request.headers['SOAPAction']
      assert_equal Salesforce::Config.login_url, request.url.to_s
    end.returns(stub_response)

    Salesforce::Config.stubs(:session_id).returns('boyahh_session_id')
    Salesforce::Config.stubs(:soap_enterprise_namespace).returns('soap:enterprise:namespace')
    
    assert_equal expected_result, Salesforce.connection.send(:invoke_soap, :login, options)
  end

  def test_soap_client
    options = {
      :namespace => 'my:name:space',
      :endpoint => 'https://my.endpoint.url.com'
    }
    
    client = Salesforce.connection.send(:soap_client, options)
    assert_equal 'https://my.endpoint.url.com', client.globals[:endpoint]
    assert_equal 'my:name:space', client.globals[:namespace]
  end

end
