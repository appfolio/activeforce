module Salesforce
  module Bulk
    class UpdateJob < Job
      
      def initialize(object_type, columns = :all)
        super(object_type, 'update', columns)
      end
      
      def csv_columns
        [ object_type.columns.id_column ] + if columns.blank? || columns == :all
          object_type.columns.updateable
        else
          columns.map do |col|
            sf_col = object_type.columns.find { |scol| scol.name == col.to_s  }
            raise UnrecognizedColumn.new("#{col} is not a valid column.") unless sf_col
            sf_col
          end
        end
      end
        
      
    end
  end
end