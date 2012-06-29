module Salesforce
  module Attributes
    extend ActiveSupport::Concern
    
    module InstanceMethods
      def assign_attributes!(hash)
        hash.each do |key, value|
          send("#{key}=", value) if respond_to?("#{key}=")
        end
      end
    end
  end
end
