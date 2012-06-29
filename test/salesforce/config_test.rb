require 'test_helper'

class Salesforce::ConfigTest < ActiveSupport::TestCase
  
  setup :clean_config
  
  def test_configure
    Salesforce.configure do
      username "foo"
      password "bar"
    end
    assert_equal "foo", Salesforce::Config.username
    assert_equal "bar", Salesforce::Config.password
    assert_equal '22.0', Salesforce::Config.api_version
    assert_equal false, Salesforce::Config.use_sandbox?
    assert_equal false, Salesforce::Config.use_full_length_ids?
  end
  
  def test_configure__username__password_can_be_blocks
    user_count = 0
    password_count = 4

    Salesforce.configure do
      username { user_count = user_count + 1 }
      password { password_count = password_count + 1 }
    end

    assert_equal 1, Salesforce::Config.username
    assert_equal 2, Salesforce::Config.username
    assert_equal 3, Salesforce::Config.username
    assert_equal 4, Salesforce::Config.username

    assert_equal 5, Salesforce::Config.password
    assert_equal 6, Salesforce::Config.password
    assert_equal 7, Salesforce::Config.password
    assert_equal 8, Salesforce::Config.password
  end
  
  def test_config__on_login_failure
    assert_nil Salesforce::Config.on_login_failure
    
    @my_stuff = 0
    
    Salesforce.configure do
      on_login_failure { @my_stuff = @my_stuff + 1 }
    end
    
    Salesforce::Config.on_login_failure
    assert_equal 1, @my_stuff
    Salesforce::Config.on_login_failure
    
    assert_equal 2, @my_stuff
  end
  
  def test_config__specific_api_version
    Salesforce.configure do
      username "foo"
      password "bar"
      api_version 21
    end
    assert_equal "foo", Salesforce::Config.username
    assert_equal "bar", Salesforce::Config.password
    assert_equal '21.0', Salesforce::Config.api_version
    assert_equal false, Salesforce::Config.use_sandbox?
  end
  
  def test_config__sandbox
    Salesforce.configure do
      username "foo"
      password "bar"
      use_sandbox
    end
    
    assert_equal "foo", Salesforce::Config.username
    assert_equal "bar", Salesforce::Config.password
    assert Salesforce::Config.use_sandbox?
  end
  
  def test_login_url__regular
    Salesforce.configure do
      username "foo"
      password "bar"
      api_version 21
    end
    
    assert_equal "https://login.salesforce.com/services/Soap/c/21.0", Salesforce::Config.login_url
  end
  
  def test_login_url__sandbox
    Salesforce.configure do
      username "foo"
      password "bar"
      use_sandbox
    end
    
    assert_equal "https://test.salesforce.com/services/Soap/c/22.0", Salesforce::Config.login_url
  end
  
  def test_passthrough_methods
    config = Salesforce::Config.instance
    config.username "username"
    assert_equal "username", Salesforce::Config.username
    config.password "password"
    assert_equal "password", Salesforce::Config.password
    config.api_version "23"
    assert_equal "23.0", Salesforce::Config.api_version
    config.use_sandbox
    assert Salesforce::Config.use_sandbox?
    assert_equal config.login_url, Salesforce::Config.login_url
    config.session_id "session_id"
    assert_equal "session_id", Salesforce::Config.session_id
    
    config.server_instance "na99"
    assert_equal "na99", Salesforce::Config.server_instance
    
    config.user_id "user_id"
    assert_equal "user_id", Salesforce::Config.user_id
    assert_equal config.server_url, Salesforce::Config.server_url
  end
  
  def test_server_url__and_server_host
    config = Salesforce::Config.instance
    config.server_instance "sa2"
    config.api_version 99
    assert_equal "https://sa2.salesforce.com/services/data/v99.0", Salesforce::Config.server_url
    assert_equal "https://sa2.salesforce.com", Salesforce::Config.server_host
  end
  
  def test_configured
    config = Salesforce::Config.instance
    assert_equal false, config.configured?
    
    config.username "username"
    assert_equal false, config.configured?
    
    config.password "password"
    assert config.configured?
    
    config.username nil
    assert_equal false, config.configured?
  end
   
  def test_soap_enterprise_namespace
    assert_equal "urn:enterprise.soap.sforce.com", Salesforce::Config.soap_enterprise_namespace
    assert_equal "urn:enterprise.soap.sforce.com", Salesforce::Config.instance.soap_enterprise_namespace
  end

  def test_use_full_length_ids?

    Salesforce.configure do
      use_full_length_ids
    end

    assert Salesforce::Config.use_full_length_ids?
  end
  
  private
  
  def clean_config
    Salesforce::Config.instance_variable_set(:@instance, nil)
  end
      
end