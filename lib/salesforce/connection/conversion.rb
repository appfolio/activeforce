module Salesforce
  module Connection
    module Conversion
      extend ActiveSupport::Concern
      module ClassMethods
        
        def convert_body(response, options)
          convert(response.body, options)
        end
        
        def convert_error(error, url, options)
          error_message = convert(error.http_body, options)
          error_message = error_message.first if error_message.is_a?(Array)
          error_message = error_message["Error"] if error_message.is_a?(Hash) && error_message["Error"]
          raise InvalidRequest.new(error_message, url)
        end
        
        def convert(body, options)
          if options[:format] == :json
            ActiveSupport::JSON.decode(body)
          elsif options[:format] == :xml
            result = Hash.from_xml(body)
            if result.is_a?(Hash) && result.keys.size == 1
              result[result.keys.first].with_indifferent_access
            else
              result.with_indifferent_access
            end
          else
            body
          end
        end
        
      end #ClassMethods
    end
  end
end

