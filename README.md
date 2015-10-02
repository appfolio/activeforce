# ActiveForce

[![Build Status](https://travis-ci.org/appfolio/activeforce.svg?branch=master)](https://travis-ci.org/appfolio/activeforce)

Activeforce provides a clean ActiveRecord-like interface to the SalesForce.com REST API.

* Detects the schema of the SalesForce Objects on the fly, so that you can interact with the familiar ActiveRecord style attribute accessor methods.
* Provides full access to all methods provided to the SQL-like Salesforce Object Query Language (SOQL).
* Integrates with Salesforce.com REST-based BULK API.

## Configuration

### Simple Usage
    Salesforce.configure do
      username "foo@bar.com"
      password "salesforcepassword"
    end
  
The password is a combination of your salesforce password and the API Token

### Specifying a particular API version

By default, activeforce uses version 22 of the Salesforce REST API. To specify another version:

    Salesforce.configure do
      username "foo@bar.com"
      password "salesforcepasswordapitoken" # This should be your salesforce password + your API Token
      api_version 18
    end

### Using the Sandbox
    Salesforce.configure do
      username "foo@bar.com.sandbox"
      password "salesforcepassword"
      end

### Finders

activeforce provides implementation for some standard Salesforce Objects like Account, Contact, Opportunity, etc

### Accessing custom objects

activeforce provides an easy way to declare models for custom objects or other SalesForce objects that are not included by default.

    class Salesforce::CustomObject < Salesforce::Base
      self.custom_object = true
    end
    
    # or 
    
    class Salesforce::Feed < Salesforce::Base
    end
    

#### Find all objects
    Salesforce::Account.all
  
#### Find Account by id
    Salesforce::Account.find("accountid")
  
#### Dynamic Finders
    Salesforce::Account.find_by_name("accountname")
  
#### Specifying conditions

    http://www.salesforce.com/us/developer/docs/api/index_Left.htm#CSHID=sforce_api_calls_soql.htm|StartTopic=Content%2Fsforce_api_calls_soql.htm|SkinName=webhelp
    
    Salesforce::Account.find(:all, :conditions => ":name = :value", :value => "my special name") 
    # Issues a SOQL query to search for all Account objects where the field 'Name' matches "my special name"
    # The SOQL Query is SELECT Id,Name,... FROM Account WHERE Name = 'my special name'
    #
    # This method of specifying columns in the query handles custom columns as well.
    Salesforce::Account.find(:all, :conditions => ":account_type = :value", :value => "Special")
    # The SOQL Query issued here is  SELECT Id,Name,... FROM Account WHERE Account_Type__c = 'Special'
    
#### Creating and Updating Objects

#### Deleting Objects

## Salesforce Bulk API

You can create and schedule a job by:
    
    job = Salesforce::Account.bulk_update do
      batch do
        record account_1 # account_1 is an object of type Salesforce::Account
        record account_2 # account_1 is an object of type Salesforce::Account
      end
    end

You can specify the columns that you want to update
    job = Salesforce::Account.bulk_update(:name, :website) do
      batch do
        record account_1 # account_1 is an object of type Salesforce::Account
        record account_2 # account_1 is an object of type Salesforce::Account
      end
    end
    

    

### Contributing to activeforce
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

### Copyright

Copyright (c) 2012 AppFolio, Inc.. See LICENSE.txt for further details.
