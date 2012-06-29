module Salesforce
  module Bulk
    class Job
      include ::Salesforce::Attributes
      
      include Blockenspiel::DSL
      
      attr_accessor :id, :operation, :object, :state, :concurrency_mode, :content_type, :number_of_batches_queued, 
                    :number_batches_in_progress, :number_batches_completed, :number_batches_failed, :number_batches_total,
                    :number_records_processed, :number_retries, :object_type, :batches, :columns
      
      [ :open, :closed, :aborted, :failed ].each do |status|
        define_method "#{status}?" do
          self.state == status.to_s.titleize
        end
      end
      
      def initialize(object_type, operation, columns = :all)
        self.object_type = object_type
        self.object = object_type.table_name
        self.operation = operation.to_s.downcase
        self.parallel!
        self.batches = []
        self.columns = columns
      end
      
      def parallel!
        self.concurrency_mode = "Parallel"
      end
      
      def serial!
        self.concurrency_mode = "Serial"
      end
      
      def batch(&block)
        Batch.new(self).tap do |batch|
          Blockenspiel.invoke(block, batch)
          self.batches << batch
        end
      end
            
      def process!
        create_job!
        create_batches!
        close_job!
      end
      
      def completed?
        self.batches.each(&:update_status)
        self.batches.all? { |batch| batch.completed? || batch.failed? }
      end
      
      def results
        self.batches.map(&:results).flatten
      end
      
      private
      
      def create_job!
        response = ::Salesforce.connection.async_post("job", create_job_xml, :format => :xml)
        assign_attributes!(response)
      end
      
      def create_batches!
        batches.each(&:create!)
      end
      
      def close_job!
        response = ::Salesforce.connection.async_post("job/#{id}", close_job_xml, :format => :xml)
        assign_attributes!(response)
      end
      
      def create_job_xml
        job_xml do |job_info|
          job_info.operation self.operation
          job_info.object    self.object
          job_info.contentType "CSV"
        end
      end
      
      def close_job_xml
        job_xml do |job_info|
          job_info.state "Closed"
        end
      end
      
      def job_xml(&block)
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.instruct!
        xml.jobInfo :xmlns => "http://www.force.com/2009/06/asyncapi/dataload" do |job_info|
          block.call(job_info)
        end
        xml.target!
      end
      
      def csv_header
        csv_columns.map(&:original_name)
      end
      
      
    end
  end
end