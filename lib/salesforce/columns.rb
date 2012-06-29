module Salesforce
  class Columns
    include Enumerable
    attr_accessor :by_name, :by_original_name, :table_name

    def initialize(table_name)
      self.table_name = table_name
      fields = Connection.fields(table_name)
      self.by_name          = {}
      self.by_original_name = {}
      fields.each do |field|
        column = Column.new(field)
        by_name[column.name] = column
        by_original_name[column.original_name] = column
      end
    end
    
    def each(&block)
      all.each(&block)
    end
    
    def all
      @all ||= by_name.values.flatten
    end
    
    def editable
      @editable ||= select(&:editable?)
    end
    
    def createable
      select(&:createable?)
    end
    
    def updateable
      select(&:updateable?)
    end
    
    def id_column
      find { |col| col.name.to_sym == :id }
    end
    
    def names
      map(&:name)
    end
    
    def soql_selector
      @soql_selector ||= by_original_name.keys.sort.join(',')
    end
    
    def ==(other)
      other && self.all.map(&:name) == other.all.map(&:name)
    end
    
    def find_by_name(name)
      column = by_name[name.to_s]
      raise ColumnNotFound.new(name, table_name) unless column
      column
    end
  end
end
