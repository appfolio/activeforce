module Salesforce
  module Connection
    module HttpMethods
      extend ActiveSupport::Concern

      module ClassMethods

        def headers(options = {})
          {'Authorization' => "OAuth #{::Salesforce::Authentication.session_id}"}.merge(content_type_headers(options))
        end

        def get(path, options = {})
          http(:get, path, nil, options)
        end

        def patch(path, body, options = {})
          http(:patch, path, body, options)
        end

        def post(path, body, options = {})
          http(:post, path, body, options)
        end
        
        def delete(path)
          true if http(:delete, path, nil, :format => :xml)
        end
        
        def salesforce_url(path)
          if path.include?("services/data")
            ::Salesforce::Config.server_host + path
          else
            ::Salesforce::Config.server_url + "/" + path
          end
        end
        
        def http(action, path, body, options)
          as_logged_in_user do
            begin
              response = if body
                RestClient.send(action, salesforce_url(path), body, headers(options))
              else
                RestClient.send(action, salesforce_url(path), headers(options))
              end

              if response.body.present?
                convert_body(response, options) 
              else
                response
              end
            rescue RestClient::ResourceNotFound, RestClient::BadRequest => e
              convert_error(e, salesforce_url(path), options)
            end
          end
        end
        
        def content_type_headers(options)
          {}.tap do |hash|
            hash[:content_type] = if options[:content_type]
               options[:content_type]
            elsif options[:format].to_s == 'json'
              "application/json"
            elsif options[:format].to_s == 'xml'
              "application/xml"
            end
          end
        end
        
      end #ClassMethods
    end
  end
end

