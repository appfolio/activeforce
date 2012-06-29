module Salesforce
  class InvalidRequest < StandardError
    attr_accessor :error_code
    
    def initialize(error_options, url)
      @error_code = error_options['errorCode']
      super("#{error_options["errorCode"]}: #{error_options["message"]} while accessing #{url}")
    end
  end
  
  class ObjectNotSupported < StandardError
    def initialize(object_name)
      super("The #{object_name} is not supported in SalesForce")
    end
  end
  
  class RecordInvalid < StandardError
    def initialize(object_name, reason)
      super("#{object_name} failed to be saved. #{reason}")
    end
  end
  
  class ColumnNotFound < StandardError
    def initialize(name, table_name)
      super("Column ''#{name}' not found for #{table_name}.")
    end
  end
  
  
  class InvalidCredentials < StandardError; end
  class ObjectDestroyed    < StandardError; end;
  class UnrecognizedColumn < StandardError; end;
end