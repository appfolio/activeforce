require 'test_helper'

class Salesforce::ColumnTest < ActiveSupport::TestCase
  def test_initializer
    col = Salesforce::Column.new("name" => "Name", "type" => "string", "updateable" => true)
    assert_equal "name", col.name
    assert_equal "Name", col.original_name
    assert_equal :string, col.type
    assert col.editable?
  end

  def test_initializer__custom
    col = Salesforce::Column.new("name" => "Name__c", "type" => "string", "updateable" => true)
    assert_equal "name", col.name
    assert_equal "Name__c", col.original_name
    assert_equal :string, col.type
    assert col.editable?
  end

  def test_initializer__not_editable
    col = Salesforce::Column.new("name" => "Name__c", "type" => "string", "updateable" => false, "createable" => false)
    assert_equal "name", col.name
    assert_equal "Name__c", col.original_name
    assert_equal :string, col.type
    assert_equal false, col.editable?
  end
  
  def test_initializer__editable
    col = Salesforce::Column.new("name" => "Name__c", "type" => "string", "updateable" => true, "createable" => false)
    assert_equal "name", col.name
    assert_equal "Name__c", col.original_name
    assert_equal :string, col.type
    assert col.editable?
    assert col.updateable?
    assert_equal false, col.createable?
    col.updateable = false
    col.createable = true
    assert col.editable?
    assert col.createable?
    assert_equal false, col.updateable?
  end
  
  def test_to_soql_value
    assert_equal "'string'", Salesforce::Column.to_soql_value('string') 
    assert_equal "TRUE", Salesforce::Column.to_soql_value(true) 
    assert_equal "FALSE", Salesforce::Column.to_soql_value(false) 
    assert_equal "NULL", Salesforce::Column.to_soql_value(nil) 
    assert_equal "2012-01-02", Salesforce::Column.to_soql_value(Date.parse('2012-01-02')) 
    assert_equal "2012-01-02T18:40:00-08:00", Salesforce::Column.to_soql_value(Time.zone.parse('2012-01-02 06:40PM')) 
    assert_equal "1", Salesforce::Column.to_soql_value(1) 
    assert_equal "1.0", Salesforce::Column.to_soql_value(1.0) 
    assert_equal "1.04", Salesforce::Column.to_soql_value(BigDecimal.new("1.04")) 
    assert_equal "'col'", Salesforce::Column.to_soql_value(:col) 
    assert_equal "('string1','string2','string3')", Salesforce::Column.to_soql_value(['string1','string2','string3'])
    assert_equal "('string1',1,2012-01-02)", Salesforce::Column.to_soql_value(['string1',1,Date.parse("2012-01-02")])
  end
  
  def test_to_csv_value
    assert_equal "string", Salesforce::Column.to_csv_value('string') 
    assert_equal "TRUE", Salesforce::Column.to_csv_value(true) 
    assert_equal "FALSE", Salesforce::Column.to_csv_value(false) 
    assert_equal "", Salesforce::Column.to_csv_value(nil) 
    assert_equal "2012-01-02", Salesforce::Column.to_csv_value(Date.parse('2012-01-02')) 
    assert_equal "2012-01-02T18:40:00-08:00", Salesforce::Column.to_csv_value(Time.zone.parse('2012-01-02 06:40PM')) 
    assert_equal "1", Salesforce::Column.to_csv_value(1) 
    assert_equal "1.0", Salesforce::Column.to_csv_value(1.0) 
    assert_equal "1.04", Salesforce::Column.to_csv_value(BigDecimal.new("1.04")) 
    assert_equal "col", Salesforce::Column.to_csv_value(:col) 
  end
  
  def test_typecast
    assert_equal "123456789012345", Salesforce::Column.typecast(:id, "123456789012345")
    assert_equal "123456789012345", Salesforce::Column.typecast(:id, "123456789012345123")
    assert_equal "123456789012345", Salesforce::Column.typecast(:reference, "123456789012345")
    assert_equal "123456789012345", Salesforce::Column.typecast(:reference, "123456789012345123")
    assert_equal Date.parse("2011-08-31"), Salesforce::Column.typecast(:date, "2011-08-31")
    assert_equal Date.parse("2011-08-31"), Salesforce::Column.typecast(:date, Date.parse("2011-08-31"))
    assert_equal nil, Salesforce::Column.typecast(:date, nil)
    assert_equal nil, Salesforce::Column.typecast(:date, 'nil')

    assert_equal Time.zone.parse('2012-01-02 06:40PM'), Salesforce::Column.typecast(:datetime, "2012-01-02 18:40:00 -08:00")
    assert_equal Time.zone.parse('2012-01-02 06:40PM'), Salesforce::Column.typecast(:datetime, Time.zone.parse('2012-01-02 06:40PM'))
    assert_equal nil, Salesforce::Column.typecast(:datetime, nil)
    assert_equal Time.now.to_s, Salesforce::Column.typecast(:datetime, 'nil').to_s

    assert_equal BigDecimal("2012"), Salesforce::Column.typecast(:double, "2012")
    assert_equal BigDecimal("2012.33"), Salesforce::Column.typecast(:double, "2012.33")
    assert_equal BigDecimal("1"), Salesforce::Column.typecast(:double, 1)
    assert_equal BigDecimal("1.2"), Salesforce::Column.typecast(:double, 1.2)
    assert_equal 0, Salesforce::Column.typecast(:double, nil)
    assert_equal 0, Salesforce::Column.typecast(:double, 'nil')
    
    assert_equal true, Salesforce::Column.typecast(:boolean, true)
    assert_equal false, Salesforce::Column.typecast(:boolean, false)
  end
  
  def test_typecast__date_max
    assert_equal nil, Salesforce::Column.typecast(:date, "9999-12-31")
    assert_equal Date.parse("4000-12-30"), Salesforce::Column.typecast(:date, "4000-12-30")
    assert_equal nil, Salesforce::Column.typecast(:datetime, "9999-12-31")
    assert_equal nil, Salesforce::Column.typecast(:datetime, "4000-12-30")
  end

  def test_typecast__date_min
    assert_equal nil, Salesforce::Column.typecast(:date, "1699-13-31")
    assert_equal nil, Salesforce::Column.typecast(:datetime, "1700-01-01")
    assert_equal nil, Salesforce::Column.typecast(:datetime, "1699-12-31")
    assert_equal Date.parse("01/01/1920").to_time, Salesforce::Column.typecast(:datetime, "1920-01-01")
  end

  def test_typecast__using_full_length_ids
    Salesforce::Config.instance.use_full_length_ids
    assert_equal "123456789012345", Salesforce::Column.typecast(:id, "123456789012345")
    assert_equal "123456789012345123", Salesforce::Column.typecast(:id, "123456789012345123")
    assert_equal "123456789012345", Salesforce::Column.typecast(:reference, "123456789012345")
    assert_equal "123456789012345123", Salesforce::Column.typecast(:reference, "123456789012345123")
  end
  
  def test_equals
    col1 = Salesforce::Column.new("name" => "Name", "type" => "string", "updateable" => true)
    col2 = Salesforce::Column.new("name" => "Name", "type" => "string", "updateable" => false)
    col3 = Salesforce::Column.new("name" => "Name__c", "type" => "string", "updateable" => true)
    
    assert col1 == col2
    assert col2 != col3
    assert col1 != col3
  end

end
