module Salesforce
  class Authentication
    cattr_accessor :username
    cattr_accessor :password
    
    def self.session_id
      raise InvalidCredentials.new("No credentials provided.") if Config.username.blank? || Config.password.blank?
      Config.session_id || generate_new_session_id
    end
    
    def self.generate_new_session_id
      result = Connection.login    
      Config.instance.soap_endpoint_url result[:server_url]
      Config.instance.session_id        result[:session_id]
      Config.instance.server_instance   URI.parse(result[:server_url]).host.split(".").first
      Config.instance.user_id           result[:user_id]
      Config.session_id
    end
    
    def self.logout
      Config.instance.session_id nil
    end
    
  end
end
