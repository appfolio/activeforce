require 'test_helper'

class Salesforce.connection::AsyncTest < ActiveSupport::TestCase
  def async_post(path, body, options = {})
    as_logged_in_user do
      convert_body RestClient.post(async_api_url(path), body, async_headers(options)), options
    end
  rescue => e
    raise e
  end
  
  def test_async_post__json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:body => { :result => 'foo' }.to_json)
    RestClient.expects(:post).with('https://.salesforce.com/services/async/22.0/path', :body, {'X-SFDC-Session' => 'session_id', :content_type => 'application/json'}).returns(http_body)
    assert_equal({'result' => 'foo'}, Salesforce.connection.async_post('path', :body, :format => :json))
  end
  
  def test_async_post__404_error_json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("[{\"message\":\"someproblem\",\"errorCode\":\"MALFORMED_QUERY\"}]")
    RestClient.stubs(:post).raises(error)
    begin
      Salesforce.connection.async_post('path', :body, :format => :json)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/async/22.0/path", e.message
    end
  end
  
  def test_async_post__404_error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:post).with('https://.salesforce.com/services/async/22.0/path', :body, {'X-SFDC-Session' => 'session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.async_post('path', :body, :format => :xml)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/async/22.0/path", e.message
    end
  end
  
  def test_async_post__400_error_json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::ResourceNotFound.new
    error.stubs(:http_body).returns("[{\"message\":\"someproblem\",\"errorCode\":\"MALFORMED_QUERY\"}]")
    RestClient.expects(:post).with('https://.salesforce.com/services/async/22.0/path', :body, {'X-SFDC-Session' => 'session_id', :content_type => 'application/json'}).raises(error)
    begin
      Salesforce.connection.async_post('path', :body, :format => :json)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/async/22.0/path", e.message
    end
  end
  
  def test_async_post__400_error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::ResourceNotFound.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:post).with('https://.salesforce.com/services/async/22.0/path', :body, {'X-SFDC-Session' => 'session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.async_post('path', :body, :format => :xml)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/async/22.0/path", e.message
    end
  end
  
  def test_async_post__xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:body => { :result => 'foo' }.to_xml)
    RestClient.expects(:post).with('https://.salesforce.com/services/async/22.0/path', :body, {'X-SFDC-Session' => 'session_id', :content_type => 'application/xml'}).returns(http_body)
    assert_equal({'result' => 'foo'}, Salesforce.connection.async_post('path', :body, :format => :xml))
  end
  
  def test_async_get__json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:body => { :result => 'foo' }.to_json)
    RestClient.expects(:get).with('https://.salesforce.com/services/async/22.0/path', {'X-SFDC-Session' => 'session_id', :content_type => 'application/json'}).returns(http_body)
    assert_equal({'result' => 'foo'}, Salesforce.connection.async_get('path', :format => :json))
  end
  
  def test_async_get__error_json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("[{\"message\":\"someproblem\",\"errorCode\":\"MALFORMED_QUERY\"}]")
    RestClient.expects(:get).with('https://.salesforce.com/services/async/22.0/path', {'X-SFDC-Session' => 'session_id', :content_type => 'application/json'}).raises(error)
    
    begin
      Salesforce.connection.async_get('path', :format => :json)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/async/22.0/path", e.message
    end
  end
  
  def test_async_get__error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:get).with('https://.salesforce.com/services/async/22.0/path', {'X-SFDC-Session' => 'session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.async_get('path', :format => :xml)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/async/22.0/path", e.message
    end
  end
  
  def test_async_get__xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:body => { :result => 'foo' }.to_xml)
    RestClient.expects(:get).with('https://.salesforce.com/services/async/22.0/path', {'X-SFDC-Session' => 'session_id', :content_type => 'application/xml'}).returns(http_body)
    assert_equal({'result' => 'foo'}, Salesforce.connection.async_get('path', :format => :xml))
  end
  
  def test_async_api_url
    assert_equal 'https://.salesforce.com/services/async/22.0/path', Salesforce.connection.async_api_url('path')
  end
  
  
  
  
  
  
  
end
