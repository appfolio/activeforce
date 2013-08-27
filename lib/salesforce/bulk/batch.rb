require 'csv'

CSVLib = RUBY_VERSION.start_with?("1.8") ? FasterCSV : CSV

module Salesforce
  module Bulk
    class Batch
      Result = Struct.new :id, :success, :created, :error
      include ::Salesforce::Attributes
      
      attr_accessor :id, :job, :number_records_failed, :number_records_processed, :state, :state_message, :total_time_processed, :filename, :csv

      include Blockenspiel::DSL
      
      def initialize(job)
        self.job = job
        self.filename = temporary_csv_file
        self.csv = CSVLib.open(self.filename, 'w+')
        self.csv << csv_header
      end
            
      def record(record)
        if record.is_a?(Hash)
          self.csv << ordered_values(record)
        else
          self.csv << ordered_values(record.attributes)
        end
      end
      
      def ordered_values(record)
        job.csv_columns.map do |col|
          raw_value = record[col.name.to_sym]
          Column.to_csv_value Column.typecast(col.type, raw_value)
        end
      end
        
      def create!
        self.csv.close
        response = ::Salesforce.connection.async_post("job/#{job.id}/batch", File.read(self.filename), :format => :xml, :content_type => 'text/csv')
        assign_attributes!(response)
      end
      
      def update_status
        return state if completed?
        response = ::Salesforce.connection.async_get("job/#{job.id}/batch/#{id}", :format => :xml)
        self.state = response[:state]
      end
      
      def results
        parse_csv_results ::Salesforce.connection.async_get("job/#{job.id}/batch/#{id}/result")
      end
      
      [ :queued, :in_progress, :completed, :failed, :not_processed ].each do |status|
        define_method "#{status}?" do
          self.state == status.to_s.titleize
        end
      end
      
      def temporary_csv_file
        if Object.const_defined?(:Rails)
          Rails.root.join('tmp', 'files', "#{ Time.now.to_i}#{rand(10000)}.csv")
        else
          File.join("/tmp/#{ Time.now.to_i}#{rand(10000)}.csv")
        end
      end
      
      private
      
      def parse_csv_results(results)
         parsed_results = CSVLib.parse(results)
         parsed_results[1..-1].map { |row| Result.new(*row) }
      end
      
      def csv_header
        self.job.csv_columns.map(&:original_name)
      end
      
      
    end
  end
end
