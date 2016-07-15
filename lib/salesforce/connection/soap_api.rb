module Salesforce
  module Connection
    module SoapApi
      extend ActiveSupport::Concern

      class Error < RuntimeError; end

      module ClassMethods

        def login
          options = { 
            :endpoint_url => Config.login_url,
            :body         => { 
              :username => Config.username, 
              :password => Config.password, 
              :order!   => [ :username, :password ] 
            } 
          }
          
          invoke_soap(:login, options)
        end
        
        def convert_lead(lead_converts)
          options = { :body => { :leadConverts => lead_converts } }
          
          as_logged_in_user do
            invoke_soap(:convertLead, options)
          end
        end
        
        protected
        
        def invoke_soap(method_name, options)
          client_options = {
            namespace: options[:namespace] ||= Config.soap_enterprise_namespace,
            endpoint: options[:endpoint_url] ||= Config.soap_endpoint_url
          }

          additional_call_options = {}
          unless method_name.to_sym == :login
            additional_call_options[:soap_header] = {
              "ns1:SessionHeader" => { "ns1:sessionId" => Config.session_id }
            }

            client_options[:namespaces] = {
              "xmlns:ns1" => Config.soap_enterprise_namespace,
            }
          end

          client = soap_client(client_options)
          result = client.call(method_name.to_sym, { message: options[:body] }.merge(additional_call_options))
          
          result.body[:"#{method_name.to_s.underscore}_response"][:result].tap do |result|
            unless result[:success] || method_name.to_sym == :login
              raise_error(method_name, options, result[:errors])
            end
          end
        end
        
        def soap_client(options)
          Savon.client(options.merge(log: false))
        end
        
        def raise_error(method_name, options, errors)
          message = <<-MSG
\n
  METHOD_NAME: #{method_name}
  OPTIONS: #{options.inspect}
  ERRORS: #{errors.inspect}
MSG
          
          raise Error.new(message)
        end
      end
      
    end
  end
end
