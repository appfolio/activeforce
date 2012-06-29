module Salesforce
  class Column
    attr_accessor :name, :original_name, :createable, :updateable, :type

    def initialize(field)
      self.original_name = field["name"]
      self.name          = field["name"].gsub(/\_\_c$/, '').underscore
      self.type          = field["type"].to_sym
      self.createable    = field['createable']
      self.updateable    = field["updateable"]
    end

    def createable?
      createable
    end

    def updateable?
      updateable
    end

    def editable?
      createable? || updateable?
    end


    def self.to_soql_value(obj)
      case (obj)
        when Date
          obj.strftime("%Y-%m-%d")
        when TrueClass
          'TRUE'
        when FalseClass
          'FALSE'
        when Time
          obj.xmlschema
        when nil
          'NULL'
        when Numeric
          "#{obj.to_s}"
        when Array
          "(#{obj.map { |sobj| to_soql_value(sobj) }.join(',')})"
        else
          "'#{obj.to_s}'"
      end
    end

    def self.to_csv_value(obj)
      case (obj)
        when Date;
          obj.strftime("%Y-%m-%d")
        when TrueClass;
          'TRUE'
        when FalseClass;
          'FALSE'
        when Time;
          obj.xmlschema
        else
          "#{obj.to_s}"
      end
    end

    def self.typecast(type, value)
      case (type)
        when :id, :reference
          if Config.use_full_length_ids?
            value
          else
            value.to_s.size == 15 ? value : value.to_s[0..14]
          end
        when :date
          begin
            Date.parse(value);
          rescue
            value if value.is_a?(Date)
          end
        when :datetime
          begin
            Time.parse(value)
          rescue
            value if value.is_a?(Time)
          end
        when :double
          begin
            BigDecimal(value.to_s)
          rescue
            value if value.is_a?(Numeric)
          end
        else
          value
      end
    end

    def ==(other)
      return false unless other
      self.name == other.name && self.original_name == other.original_name
    end
  end
end
