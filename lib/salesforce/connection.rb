require 'salesforce/connection/soap_api'
require 'salesforce/connection/rest_api'
require 'salesforce/connection/http_methods'
require 'salesforce/connection/conversion'
require 'salesforce/connection/async'

module Salesforce
  module Connection
    include SoapApi
    include RestApi
    include HttpMethods
    include Conversion
    include Async
    
    def self.as_logged_in_user(&block)
      count = 0 
      begin
        Salesforce::Authentication.session_id
        block.call
      rescue RestClient::Request::Unauthorized, Savon::SOAPFault => e
        if count < 1 && (e.message.downcase.include?("unauthorized") || e.message.downcase.include?("invalid_login"))
          count += 1
          Salesforce::Config.on_login_failure
          Salesforce::Authentication.logout
          retry
        else
          raise e
        end
      end
    
    end
  end
end
