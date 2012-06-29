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
    
    soap_client_mock = mock
    Salesforce.connection.expects(:soap_client).with(options).returns(soap_client_mock)

    Salesforce::Config.stubs(:session_id).returns('boyahh_session_id')
    Salesforce::Config.stubs(:soap_enterprise_namespace).returns('soap:enterprise:namespace')

    soap_mock = mock
    soap_mock.expects(:body=).with(:soap_body)
    soap_mock.expects(:header=).with({ "ns1:SessionHeader" => { "ns1:sessionId" => 'boyahh_session_id' }})
    
    
    namespaces_mock = mock
    namespaces_mock.expects(:[]=).with("xmlns:ns1", 'soap:enterprise:namespace')
    soap_mock.expects(:namespaces).returns(namespaces_mock)
    
    soap_client_mock.expects(:request).with(:wsdl, :notLogin).yields(soap_mock).returns(mock(:to_hash => result))
    
    assert_equal expected_result, Salesforce.connection.send(:invoke_soap, :notLogin, options)    
  end

  def test_invoke_soap__not_login__not_success
    options = {
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
    
    soap_client_mock = mock
    Salesforce.connection.expects(:soap_client).with(options).returns(soap_client_mock)

    Salesforce::Config.stubs(:session_id).returns('boyahh_session_id')
    Salesforce::Config.stubs(:soap_enterprise_namespace).returns('soap:enterprise:namespace')

    soap_mock = mock
    soap_mock.expects(:body=).with(:soap_body)
    soap_mock.expects(:header=).with({ "ns1:SessionHeader" => { "ns1:sessionId" => 'boyahh_session_id' }})
    
    
    namespaces_mock = mock
    namespaces_mock.expects(:[]=).with("xmlns:ns1", 'soap:enterprise:namespace')
    soap_mock.expects(:namespaces).returns(namespaces_mock)
    
    soap_client_mock.expects(:request).with(:wsdl, :notLogin).yields(soap_mock).returns(mock(:to_hash => result))
    
    assert_raises Salesforce::Connection::SoapApi::Error do
      Salesforce.connection.send(:invoke_soap, :notLogin, options)
    end
  end

  def test_invoke_soap__login
    options = {
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
    
    soap_client_mock = mock
    Salesforce.connection.expects(:soap_client).with(options).returns(soap_client_mock)

    soap_mock = mock
    soap_mock.expects(:body=).with(:soap_body)
    soap_client_mock.expects(:request).with(:wsdl, :login).yields(soap_mock).returns(mock(:to_hash => result))
    
    assert_equal expected_result, Salesforce.connection.send(:invoke_soap, :login, options)
  end

  def test_soap_client
    options = {
      :namespace => 'my:name:space',
      :endpoint_url => 'https://my.endpoint.url.com'
    }
    
    client = Salesforce.connection.send(:soap_client, options)
    assert_equal 'https://my.endpoint.url.com', client.wsdl.endpoint
    assert_equal 'my:name:space', client.wsdl.namespace
  end

end