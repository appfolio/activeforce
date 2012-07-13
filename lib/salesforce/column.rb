module Salesforce
  class Column
    attr_accessor :name, :original_name, :createable, :updateable, :type

    MAX_SUPPORTED_DATE = Date.parse("12/31/4000")

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
            if parsed_date > MAX_SUPPORTED_DATE
              nil
            else
              parsed_date
            end
          rescue
            value if value.is_a?(Date)
          end
        when :datetime
          begin
            parsed_time = Time.parse(value)
            if parsed_time > MAX_SUPPORTED_DATE.to_time
              nil
            else
              parsed_time
            end
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
