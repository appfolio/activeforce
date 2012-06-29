module Salesforce
  class Config

    DEFAULT_API_VERSION = "22.0"

    include Blockenspiel::DSL
    include Blockenspiel::DSLSetupMethods

    dsl_attr_accessor :session_id, :server_instance, :user_id, :soap_endpoint_url

    [
      :username, :password, :api_version, :use_sandbox?, :use_full_length_ids?,
      :login_url, :session_id, :server_instance, :soap_endpoint_url, :soap_enterprise_namespace,
      :user_id, :server_url, :server_host, :async_url, :configured?, :on_login_failure ].each do |method_name|
      eval <<-RUBY
      def self.#{method_name}
        instance.#{method_name}
      end
      RUBY
    end

    def self.instance
      @instance ||= new
    end

    def username(*args, &block)
      if block.present?
        @username = Proc.new { block.call }
      elsif args.present?
        @username = args.first
      elsif @username.respond_to?(:call)
        @username.call
      else
        @username
      end
    end

    def password(*args, &block)
      if block.present?
        @password = Proc.new { block.call }
      elsif args.present?
        @password = args.first
      elsif @password.respond_to?(:call)
        @password.call
      else
        @password
      end
    end

    def api_version(val = nil)
      if val
        @api_version = val.to_f.to_s
      else
        @api_version || DEFAULT_API_VERSION
      end
    end

    def use_sandbox?
      @use_sandbox || false
    end

    def use_full_length_ids?
      @use_full_length_ids || false
    end

    def use_full_length_ids
      @use_full_length_ids = true
    end

    def use_sandbox
      @use_sandbox = true
    end

    def on_login_failure(&block)
      if block.present?
        @on_login_failure = Proc.new { block.call }
      else
        @on_login_failure.try(:call)
      end
    end

    def configured?
      username.present? && password.present?
    end

    def soap_enterprise_namespace
      'urn:enterprise.soap.sforce.com'
    end

    def server_url
      "https://#{server_instance}.salesforce.com/services/data/v#{api_version}"
    end

    def server_host
      "https://#{server_instance}.salesforce.com"
    end

    def async_url
      "https://#{server_instance}.salesforce.com/services/async/#{api_version}"
    end

    def login_url
      login_url_base + api_version
    end

    def login_url_base
      use_sandbox? ? 'https://test.salesforce.com/services/Soap/c/' : 'https://login.salesforce.com/services/Soap/c/'
    end
  end
end
