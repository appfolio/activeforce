module Salesforce
  class Base
    class_attribute :custom_object, :custom_table_name, :cached_columns, :attributes
    include ::Salesforce::Bulk::Operations

    self.custom_object = false
    
    def initialize(attrs = {})
      self.class.columns
      assign_attributes(attrs)
    end
    
    def assign_attributes(attrs)
      attrs.delete("attributes")
      attrs.each do |k,v|
        send("#{k}=", v)
      end
    end

    def self.table_name
      return self.custom_table_name if self.custom_table_name
      name.demodulize + (self.custom_object ? "__c" : '')
    end

    def self.columns
      self.cached_columns ||= begin
        cols = Columns.new(table_name)
        cols.all.each do |col| 
          attr_reader col.name
          
          define_method "#{col.original_name}=" do |value|
            instance_variable_set(:"@#{col.name}", Column.typecast(col.type, value))
          end
        end

        cols.editable.each do |col|
          define_method "#{col.name}=" do |value|
            if (new_record? && col.createable?) || (!new_record? && col.updateable?)
              instance_variable_set(:"@#{col.name}", Column.typecast(col.type, value))
            else
              raise ArgumentError.new("#{self.class.table_name}##{col.name} is not editable.")
            end
          end
        end
        cols
      end
    end
    
    ## Attributes
    
    def attributes
      self.class.columns.names.inject(ActiveSupport::HashWithIndifferentAccess.new) do |hash,name|
        hash[name] = self.send(name)
        hash
      end
    end
    
    def createable_attributes
      self.class.columns.createable.inject(ActiveSupport::HashWithIndifferentAccess.new) do |hash,col|
        value = self.send(col.name)
        hash[col.original_name] = value unless value.nil?
        hash
      end
    end
    
    def updateable_attributes
      self.class.columns.updateable.inject(ActiveSupport::HashWithIndifferentAccess.new) do |hash,col|
        value = self.send(col.name)
        hash[col.original_name] = value unless value.nil?
        hash
      end
    end
    
    def attributes=(attrs)
      assign_attributes(attrs)
    end

    ## Finders
    
    def self.find(*args)
      if args.first == :all
        find_all(*args)
      else 
        find_by_id(*args)
      end
    end
    
    def self.find_by_id(object_id)
      with_invalid_column_handling do
        to_object(connection(:find_object_by_id, table_name, object_id, columns.soql_selector))
      end
    end
        
    def self.find_all(*args)
      with_invalid_column_handling do 
        options = args.extract_options!
        connection(:soql, query_string(options)).map { |result| to_object(result) }
      end
    end
    
    def self.all; find_all; end

    def self.find_by_column(column, value)
      connection(:soql, "#{select_clause} FROM #{table_name} WHERE #{column.original_name}=#{Column.to_soql_value(value)}").map { |result| to_object(result) }
    end
    
    def self.select_values(options)
      connection(:soql, query_string(options)).map do |result|
        {}.tap do |hash|
          Array.wrap(options[:select] || columns.names).each do |col|
            column = columns.find_by_name(col)
            hash[col] = Column.typecast(column.type, result[column.original_name])
          end
        end
      end
    end
    
    def self.with_invalid_column_handling
      _count = 0
      begin
        yield
      rescue InvalidRequest => e
        if e.error_code == 'INVALID_FIELD' && _count == 0
          clear_cached_columns!
          _count += 1
          retry
        else
          raise e
        end
      end
    end
    
    def self.clear_cached_columns!
      self.cached_columns = nil
    end
    
    def save!
      raise_if_destroyed
      new_record? ? create : update
    end
        
    def create
      raise_if_destroyed
      self.Id = self.class.connection(:create, self.class.table_name, createable_attributes)
    end
    
    def update
      self.class.with_invalid_column_handling do 
        raise_if_destroyed
        self.class.connection(:update, self.class.table_name, self.id, updateable_attributes)
      end
    end
    
    def destroy
      raise_if_destroyed
      self.class.connection(:destroy, self.class.table_name, self.id) unless new_record?
      @destroyed = true
    end
    
    def destroyed?
      @destroyed || false
    end
    
    def raise_if_destroyed
      raise ObjectDestroyed.new if destroyed?
    end
    
    def new_record?
      self.id.blank?
    end
    
    def self.select_clause(select = nil)
      "SELECT #{selector(select)}"
    end
    
    def self.selector(select = nil)
      select ||= :all
      return columns.soql_selector if select == :all
      Array.wrap(select).map { |var| columns.find_by_name(var).original_name }.join(',')
    end
    
    def self.query_string(options)
      str = [].tap do |string|
        string << "SELECT #{selector(options[:select])} FROM #{table_name}"
        string << "WHERE #{soql_clause(options[:conditions])}" if options[:conditions]
        string << "LIMIT #{soql_clause(options[:limit])}" if options[:limit]
        string << "WITH #{soql_clause(options[:with])}" if options[:with]
        string << "GROUP BY #{soql_clause(options[:group_by])}" if options[:group_by]
        string << "HAVING #{soql_clause(options[:having])}" if options[:having]
        string << "ORDER BY #{soql_clause(options[:order])}" if options[:order]
      end.join(' ')
      sanitized_soql(str, options)
    end
    
    def self.soql_clause(sub_clause)
      return sub_clause if sub_clause.is_a?(String)
      Array.wrap(sub_clause).map { |col| columns.find_by_name(col).original_name }.join(',')
    end
    
    def self.sanitized_soql(string, values = nil)
      values ||= {}
      # Substitute columns
      columns.each do |col|
        string.gsub!(":#{col.name}", col.original_name)
      end
      
      # Substitute Values
      values.each do |key, value|
        next if [ :select, :conditions, :limit, :with, :group_by, :having, :order ].include?(key.to_sym)
        string.gsub!(":#{key}", Column.to_soql_value(value))
      end
      string
    end
    
        
    def self.connection(method, *args)
      columns
      Connection.send method, *args
    end

    def self.method_missing(method_name, *args)
      if method_name.to_s =~ /^find_by_([_a-zA-Z]\w*)$/ && column = columns.find { |column| column.name.to_s == $1 }
        self.find_by_column(column, *args)
      else
        super
      end
    end
    
    def self.to_object(result)
      result.delete("attributes")
      new.tap do |record|
        result.each do |k, v|
          if record.respond_to?(:"#{k}=")
            record.send("#{k}=", v) 
          end
        end
      end
    end
  end
end