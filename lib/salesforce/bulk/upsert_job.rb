module Salesforce
  module Bulk
    class UpsertJob < Job

      attr_accessor :external_id_col

      def initialize(object_type, external_id_col, columns = :all)
        super(object_type, 'upsert', columns)
        self.external_id_col = object_type.columns.find { |scol| scol.name == external_id_col.to_s  }
        raise UnrecognizedColumn.new("#{external_id_col} is not a valid column.") unless self.external_id_col
      end

      def csv_columns
        if columns.blank? || columns == :all
          ([self.external_id_col] + object_type.columns.editable).uniq
        else
          cols = columns.map do |col|
            sf_col = object_type.columns.find { |scol| scol.name == col.to_s  }
            raise UnrecognizedColumn.new("#{col} is not a valid column.") unless sf_col
            sf_col
          end
          ([self.external_id_col] + cols).uniq
        end
      end

      def create_job_xml
        job_xml do |job_info|
          job_info.operation self.operation
          job_info.object self.object
          job_info.externalIdFieldName self.external_id_col.original_name
          job_info.contentType "CSV"
        end
      end


    end
  end
end