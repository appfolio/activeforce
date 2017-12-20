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

      host = URI.parse(result[:server_url]).host
      host_match = host.match(/(?<instance>[a-z0-9\-]+)\.(?<domain>(?:my\.)?salesforce\.com)/)

      Config.instance.server_instance   host_match[:instance]
      Config.instance.server_domain     host_match[:domain]
      Config.instance.user_id           result[:user_id]
      Config.session_id
    end
    
    def self.logout
      Config.instance.session_id nil
    end
    
  end
end
