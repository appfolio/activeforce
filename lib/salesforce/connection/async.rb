module Salesforce
  module Connection
    module Async
      extend ActiveSupport::Concern
      
      module ClassMethods
        def async_post(path, body, options = {})
          url = async_api_url(path)
          as_logged_in_user do
            convert_body(RestClient.post(url, body, async_headers(options)), options)
          end
        rescue RestClient::ResourceNotFound, RestClient::BadRequest => e
          convert_error(e, url, options)
        end

        def async_get(path, options = {})
          url = async_api_url(path)
          as_logged_in_user do
            convert_body RestClient.get(url, async_headers(options)), options
          end
        rescue RestClient::ResourceNotFound, RestClient::BadRequest => e
          convert_error(e, url, options)
        end
        
        def async_api_url(path)
          ::Salesforce::Config.async_url + "/" + path
        end
        
        def async_headers(options)
          { 'X-SFDC-Session' => Salesforce::Authentication.session_id }.merge(content_type_headers(options))
        end 

      end
    end
  end
end
