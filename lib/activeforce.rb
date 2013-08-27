require 'pp'
require 'blockenspiel'
require 'savon'
require 'rest-client'
require 'fastercsv'
require 'active_support/all'
require 'ruby_187_range_extension'
require 'salesforce/config'
require 'salesforce/engine'
require 'salesforce/authentication'
require 'salesforce/attributes'
require 'salesforce/errors'
require 'salesforce/connection'
require 'salesforce/columns'
require 'salesforce/column'
require 'salesforce/bulk/operations'
require 'salesforce/base'
require 'salesforce/bulk/job'
require 'salesforce/bulk/update_job'
require 'salesforce/bulk/batch'

module Salesforce
  def self.configure(&block)
    Blockenspiel.invoke(block, Config.instance)
  end
  
  def self.connection
    Connection
  end
end
