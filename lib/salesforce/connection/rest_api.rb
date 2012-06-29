module Salesforce
  module Connection
    module RestApi
      extend ActiveSupport::Concern
      module ClassMethods

        def supported_objects
          get("sobjects.json", :format => :json)["sobjects"].map { |hash| hash["name"] }
        end

        def fields(object_name)
          raise ObjectNotSupported.new(object_name) unless supported_objects.include?(object_name)
          get("sobjects/#{object_name}/describe.json", :format => :json)["fields"]
        end

        def find_object_by_id(object_name, object_id, fields)
          get("sobjects/#{object_name}/#{object_id}.json?fields=#{URI.encode(fields)}", :format => :json)
        end

        def soql(query_string)
          records = []
          response = get "query.json?q=#{CGI.escape(query_string)}", :format => :json
          records += response["records"].each { |r| r.delete("attributes")}
          while(!response["done"])
            response = get((response["nextRecordsUrl"] + '.json'), :format => :json)
            records += response["records"].each { |r| r.delete("attributes")}
          end
          records
        end

        def update(object_name, object_id, fields)
          response = patch("sobjects/#{object_name}/#{object_id}.json", fields.to_json, :format => :json)
          response.code == 204
        end

        def create(object_name, fields)
          result = post("sobjects/#{object_name}.json", fields.to_json, :format => :json)
          if result["success"]
            return result["id"]
          else
            raise RecordInvalid.new(object_name, result["errors"])
          end
        end

        def destroy(object_name, object_id)
          delete("sobjects/#{object_name}/#{object_id}")
        end
        
      end
    end
  end
end
