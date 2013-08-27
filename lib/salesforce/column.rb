module Salesforce
  class Column
    attr_accessor :name, :original_name, :createable, :updateable, :type
    
    SUPPORTED_DATE_RANGE =  Date.parse("1700-01-01")..Date.parse("4000-12-31")
    SUPPORTED_TIME_RANGE =  Time.parse("1902-01-01 00:00:00 UTC")..Time.parse("2037-12-31 00:00:00 UTC")

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
            parsed_date = Date.parse(value)
            if SUPPORTED_DATE_RANGE.cover?(parsed_date)
              parsed_date
            else
              nil
            end
          rescue ArgumentError
            nil
          rescue
            value if value.is_a?(Date)
          end
        when :datetime
          begin
            parsed_time = Time.parse(value)
            if SUPPORTED_TIME_RANGE.cover?(parsed_time)
              parsed_time
            else
              nil
            end
          rescue ArgumentError
            Time.now
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
