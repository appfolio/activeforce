require 'test_helper'

class Salesforce::AuthenticationTest < ActiveSupport::TestCase
  def test_session_id__exists
    Salesforce.configure do
      username "username"
      password "password"
    end
    Salesforce::Authentication.expects(:generate_new_session_id).never
    Salesforce::Config.instance.session_id "existingsessionid"
    assert_equal "existingsessionid", Salesforce::Authentication.session_id
  end
  
  def test_session_id__doesnotexist
    Salesforce.configure do
      username "username"
      password "password"
    end
    Salesforce::Authentication.expects(:generate_new_session_id).returns("new_session_id")
    assert_equal "new_session_id", Salesforce::Authentication.session_id
  end
  
  def test_session_id__credentials_missing
    Salesforce::Authentication.expects(:generate_new_session_id).never
    assert_raises Salesforce::InvalidCredentials do
      Salesforce::Authentication.session_id
    end
  end
  
  def test_logout
    Salesforce::Config.instance.session_id = "session_id"
    Salesforce::Authentication.logout
    assert_equal nil, Salesforce::Config.session_id
  end
    
  def test_generate_new_session_id__calls_connection_login
    result = {
      :session_id => "session_id",
      :server_url => "https://cs99.salesforce.com/services/Soap/c/22.0/00DQ00000001LRX",
      :user_id    => "user_id"
    }

    Salesforce.connection.expects(:login).returns(result)

    assert_equal "session_id", Salesforce::Authentication.generate_new_session_id
    assert_equal "https://cs99.salesforce.com/services/Soap/c/22.0/00DQ00000001LRX", Salesforce::Config.soap_endpoint_url
    assert_equal "session_id", Salesforce::Config.session_id
    assert_equal "cs99", Salesforce::Config.server_instance
    assert_equal "salesforce.com", Salesforce::Config.server_domain
    assert_equal "user_id", Salesforce::Config.user_id
  end

  def test_generate_new_session_id__calls_connection_login__my_domain
    result = {
      :session_id => "session_id",
      :server_url => "https://awesome-2000.my.salesforce.com/services/Soap/c/22.0/00DQ00000001LRX",
      :user_id    => "user_id"
    }

    Salesforce.connection.expects(:login).returns(result)

    assert_equal "session_id", Salesforce::Authentication.generate_new_session_id
    assert_equal "https://awesome-2000.my.salesforce.com/services/Soap/c/22.0/00DQ00000001LRX", Salesforce::Config.soap_endpoint_url
    assert_equal "session_id", Salesforce::Config.session_id
    assert_equal "awesome-2000", Salesforce::Config.server_instance
    assert_equal "my.salesforce.com", Salesforce::Config.server_domain
    assert_equal "user_id", Salesforce::Config.user_id
  end
  
end
