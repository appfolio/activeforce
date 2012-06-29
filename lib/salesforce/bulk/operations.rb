module Salesforce
  module Bulk
    module Operations
      extend ActiveSupport::Concern
      
      module ClassMethods
# Create a bulk update job
# job = Salesforce::Account.bulk_update do
#   batch do
#     record account_1
#     record account_2
#   end
# end
# 

        def bulk_update(columns = [], &block)
          UpdateJob.new(self, columns).tap do |job|
            Blockenspiel.invoke(block, job)
            job.process!
          end
        end
      end
    end
  end
end
