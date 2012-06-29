require 'test_helper'

class Salesforce.connection::HttpMethodsTest < ActiveSupport::TestCase
  def test_content_type_headers
    assert_equal({ :content_type => 'application/json'}, Salesforce.connection.content_type_headers(:format => :json))
    assert_equal({ :content_type => 'application/json'}, Salesforce.connection.content_type_headers(:format => "json"))
    assert_equal({ :content_type => 'application/xml'}, Salesforce.connection.content_type_headers(:format => :xml))
    assert_equal({ :content_type => 'application/xml'}, Salesforce.connection.content_type_headers(:format => 'xml'))
    assert_equal({ :content_type => 'foobar'}, Salesforce.connection.content_type_headers(:content_type => 'foobar'))
    assert_equal({ :content_type => nil }, Salesforce.connection.content_type_headers(:format => 'foobar'))
  end
  
  def test_get__json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:body => { :result => 'foo' }.to_json)
    RestClient.expects(:get).with('https://.salesforce.com/services/data/v22.0/path', {'Authorization' => 'OAuth session_id', :content_type => 'application/json'}).returns(http_body)
    assert_equal({'result' => 'foo'}, Salesforce.connection.get('path', :format => :json))
  end
  
  def test_get__error_json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("[{\"message\":\"someproblem\",\"errorCode\":\"MALFORMED_QUERY\"}]")
    RestClient.expects(:get).with('https://.salesforce.com/services/data/v22.0/path', {'Authorization' => 'OAuth session_id', :content_type => 'application/json'}).raises(error)
    
    begin
      Salesforce.connection.get('path', :format => :json)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_get__error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:get).with('https://.salesforce.com/services/data/v22.0/path', {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.get('path', :format => :xml)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_get__xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:body => { :result => 'foo' }.to_xml)
    RestClient.expects(:get).with('https://.salesforce.com/services/data/v22.0/path', {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).returns(http_body)
    assert_equal({'result' => 'foo'}, Salesforce.connection.get('path', :format => :xml))
  end
  
  def test_patch__json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:code => 204, :body => '')
    RestClient.expects(:patch).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/json'}).returns(http_body)
    assert Salesforce.connection.patch('path', :body, :format => :json)
  end
  
  def test_patch__400_error_json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("[{\"message\":\"someproblem\",\"errorCode\":\"MALFORMED_QUERY\"}]")
    RestClient.expects(:patch).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/json'}).raises(error)
    begin
      Salesforce.connection.patch('path', :body, :format => :json)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_patch__400_error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:patch).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.patch('path', :body, :format => :xml)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_patch__404_error_json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::ResourceNotFound.new
    error.stubs(:http_body).returns("[{\"message\":\"someproblem\",\"errorCode\":\"MALFORMED_QUERY\"}]")
    RestClient.expects(:patch).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/json'}).raises(error)
    begin
      Salesforce.connection.patch('path', :body, :format => :json)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_patch__404_error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::ResourceNotFound.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:patch).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.patch('path', :body, :format => :xml)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_patch__xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:code => 204, :body => '')
    RestClient.expects(:patch).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).returns(http_body)
    assert Salesforce.connection.patch('path', :body, :format => :xml)
  end
  

  def test_post__json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:body => { :result => 'foo' }.to_json)
    RestClient.expects(:post).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/json'}).returns(http_body)
    assert_equal({'result' => 'foo'}, Salesforce.connection.post('path', :body, :format => :json))
  end
  
  def test_post__400_error_json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("[{\"message\":\"someproblem\",\"errorCode\":\"MALFORMED_QUERY\"}]")
    RestClient.expects(:post).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/json'}).raises(error)
    begin
      Salesforce.connection.post('path', :body, :format => :json)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_post__404_error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:post).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.post('path', :body, :format => :xml)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_post__400_error_json
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::ResourceNotFound.new
    error.stubs(:http_body).returns("[{\"message\":\"someproblem\",\"errorCode\":\"MALFORMED_QUERY\"}]")
    RestClient.expects(:post).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/json'}).raises(error)
    begin
      Salesforce.connection.post('path', :body, :format => :json)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_post__400_error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::ResourceNotFound.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:post).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.post('path', :body, :format => :xml)
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_post__xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    http_body = stub(:body => { :result => 'foo' }.to_xml)
    RestClient.expects(:post).with('https://.salesforce.com/services/data/v22.0/path', :body, {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).returns(http_body)
    assert_equal({'result' => 'foo'}, Salesforce.connection.post('path', :body, :format => :xml))
  end
  
  def test_delete__400_error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::BadRequest.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:delete).with('https://.salesforce.com/services/data/v22.0/path', {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.delete('path')
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_delete__404_error_xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    error = RestClient::ResourceNotFound.new
    error.stubs(:http_body).returns("<?xml version=\"1.0\" encoding=\"UTF-8\"?><Errors><Error><errorCode>MALFORMED_QUERY</errorCode><message>someproblem</message></Error></Errors>" )
    RestClient.expects(:delete).with('https://.salesforce.com/services/data/v22.0/path', {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).raises(error)
    
    begin
      Salesforce.connection.delete('path')
      assert false, "Shouldn't have gotten here"
    rescue => e
      assert_equal "Salesforce::InvalidRequest", e.class.name
      assert_equal "MALFORMED_QUERY: someproblem while accessing https://.salesforce.com/services/data/v22.0/path", e.message
    end
  end
  
  def test_delete__xml
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    RestClient.expects(:delete).with('https://.salesforce.com/services/data/v22.0/path', {'Authorization' => 'OAuth session_id', :content_type => 'application/xml'}).returns(stub(:body => ''))
    assert Salesforce.connection.delete('path')
  end
  
  def test_salesforce_url
    assert_equal 'https://.salesforce.com/services/data/v22.0/path', Salesforce.connection.salesforce_url("path")
    assert_equal 'https://.salesforce.com/services/data/23.0/foo', Salesforce.connection.salesforce_url("/services/data/23.0/foo")
  end  
end