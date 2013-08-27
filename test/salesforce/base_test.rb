require 'test_helper'

class Salesforce::OriginalTable < Salesforce::Base
end

class Salesforce::CustomTable < Salesforce::Base
  self.custom_object = true
end

class Salesforce::BaseTest < ActiveSupport::TestCase
  
  setup :clear_columns
  
  def test_table_name
    assert_equal "OriginalTable", Salesforce::OriginalTable.table_name
    assert_equal "CustomTable__c", Salesforce::CustomTable.table_name
    Salesforce::CustomTable.custom_table_name = "this_is_your_name"
    assert_equal "this_is_your_name", Salesforce::CustomTable.table_name
  ensure
    Salesforce::CustomTable.custom_table_name = nil
  end
  
  def test_columns
    setup_columns_for_custom_table    
    obj = Salesforce::CustomTable.new(:name => "tushar", :account => "account")
    assert_equal "tushar", obj.name
    assert_equal "account", obj.account
    
    obj = Salesforce::CustomTable.new
    obj.name = "tushar"
    assert_equal "tushar", obj.name
    
    obj = Salesforce::CustomTable.new
    obj.Name__c = "tushar"
    obj.Car__c  = "Ferrari"
    obj.Id   = "newid"
    assert_equal "tushar", obj.name
    assert_equal "Ferrari", obj.car
    assert_equal "newid", obj.id
  end
  
  def test_column_attr_createable_columns__new_record
    setup_columns_for_custom_table
    obj = Salesforce::CustomTable.new
    assert_nothing_raised do
      obj.account = "account"
      obj.name = "foo"
      obj.attributes = { :account => 'account2', :name => 'foo'}
      assert_equal 'account2', obj.account
      assert_equal 'foo', obj.name
    end
    
    assert_raises ArgumentError do
      obj.car = "car"
    end
    
    assert_raises ArgumentError do
      obj.attributes = { :car => 'car2'}
    end
    
    assert_raises NoMethodError do
      obj.id = "id"
    end
    
    assert_raises NoMethodError do
      obj.attributes = { :id => 'id2'}
    end
  end
  
  def test_attributes__creatable_and_updateable
    setup_columns_for_custom_table
    obj = Salesforce::CustomTable.new("Id"=> "id", "Account__c" => "account", "Car__c" => 'car', "Name__c" => 'name')
    assert_equal({"name"=>"name", "account"=>"account", "id"=>"id", "car"=>"car"}, obj.attributes)
    assert_equal({"Account__c"=>"account", "Name__c"=>"name"}, obj.createable_attributes)
    assert_equal({"Car__c"=>"car", "Name__c"=>"name"}, obj.updateable_attributes)
  end
  
  def test_column_attr_updateable_columns__existing_record
    setup_columns_for_custom_table
    obj = Salesforce::CustomTable.new("Id" => "id")
    
    assert_nothing_raised do
      obj.name = "foo"
      obj.car = "car"
      obj.attributes = { :name => 'foo2', :car => 'car2' }
      assert_equal 'foo2', obj.name
      assert_equal 'car2', obj.car
    end
    
    assert_raises ArgumentError do
      obj.account = "account"
    end
    
    assert_raises ArgumentError do
      obj.attributes = { :account => 'account2' }
    end
    
    
    
    assert_raises NoMethodError do
      obj.id = "id"
    end
    
    assert_raises NoMethodError do
      obj.attributes = { :id => 'id' }
    end
  end
  
  def test_save__create
    setup_columns_for_custom_table
    Salesforce.connection.expects(:create).with('CustomTable__c', { 'Account__c' => 'account', "Name__c" => "name"}).returns("newid")
    obj = Salesforce::CustomTable.new(:account => 'account', :name => 'name')
    obj.save!
    assert_equal 'newid', obj.id
    assert_equal false, obj.new_record?
  end
  
  def test_save__create_fails
    setup_columns_for_custom_table
    error = Salesforce::RecordInvalid.new('CustomTable__c', 'msg')
    Salesforce.connection.expects(:create).raises(error)
    obj = Salesforce::CustomTable.new(:account => 'account', :name => 'name')
    assert_raises Salesforce::RecordInvalid do
      obj.save!
    end
    assert obj.new_record?
  end
  
  def test_save__update
    setup_columns_for_custom_table
    Salesforce.connection.expects(:update).with('CustomTable__c', 'oldid', {'Name__c' => 'newname', 'Car__c' => 'mycar'})
    obj = Salesforce::CustomTable.new(:Account__c => 'account', :name => 'newname', :Id => "oldid", :Car__c => 'mycar')
    assert_equal false, obj.new_record?
    obj.save!
  end
  
  def test_update__wrapped_by_with_invalid_column_handling
    Salesforce::OriginalTable.stubs(:columns)
    Salesforce::OriginalTable.expects(:with_invalid_column_handling).returns(:update_result)
    assert_equal :update_result, Salesforce::OriginalTable.new.update
  end  

  def test_save__update_fails
    setup_columns_for_custom_table
    error = Salesforce::RecordInvalid.new('CustomTable__c', 'msg')
    Salesforce.connection.expects(:update).raises(error)
    obj = Salesforce::CustomTable.new(:Account__c => 'account', :name => 'newname', :Id => "oldid", :Car__c => 'mycar')
    assert_raises Salesforce::RecordInvalid do
      obj.save!
    end
  end
  
  def test_destroy
    setup_columns_for_custom_table
    Salesforce.connection.expects(:destroy).with('CustomTable__c', 'oldid')
    obj = Salesforce::CustomTable.new(:Account__c => 'account', :name => 'newname', :Id => "oldid")
    obj.destroy
    assert obj.destroyed?
    assert_raises Salesforce::ObjectDestroyed do
      obj.save!
    end
    
    assert_raises Salesforce::ObjectDestroyed do
      obj.destroy
    end
    
    assert_raises Salesforce::ObjectDestroyed do
      obj.create
    end
    
    assert_raises Salesforce::ObjectDestroyed do
      obj.update
    end
  end
  
  def test_destroy__new_record
    setup_columns_for_custom_table
    Salesforce.connection.expects(:destroy).never
    obj = Salesforce::CustomTable.new(:Account__c => 'account', :name => 'newname')
    assert obj.new_record?
    obj.destroy
    assert obj.destroyed?
    assert_raises Salesforce::ObjectDestroyed do
      obj.save!
    end
    
    assert_raises Salesforce::ObjectDestroyed do
      obj.destroy
    end
    
    assert_raises Salesforce::ObjectDestroyed do
      obj.create
    end
    
    assert_raises Salesforce::ObjectDestroyed do
      obj.update
    end
  end
  
  
  def test_find
    Salesforce::OriginalTable.expects(:find_by_id).with("id")
    Salesforce::OriginalTable.find("id")
    
    Salesforce::OriginalTable.expects(:find_all)
    Salesforce::OriginalTable.find(:all)
  end
  
  def test_find_by_id
    setup_columns_for_original_table
    Salesforce.connection.expects(:find_object_by_id).with("OriginalTable", "id", "Col1,Col2__c").returns({ "Col1" => 'col11', "Col2__c" => 'col21'})
    result =  Salesforce::OriginalTable.find_by_id("id")
    assert_equal "col11", result.col1
    assert_equal "col21", result.col2
  end
  
  def test_find_by_id__wrapped_by_with_invalid_column_handling
    Salesforce::OriginalTable.expects(:with_invalid_column_handling).returns(:find_by_id_result)
    
    assert_equal :find_by_id_result, Salesforce::OriginalTable.find_by_id(anything)
  end
  
  def test_find_by_id__columns_not_set
    columns_hash = [{"name" => "Col1", "type" => "id"}, { "name" => "Col2__c", "type" => "string" } ]
    columns      = columns_hash.map { |hash| Salesforce::Column.new(hash) }
    Salesforce.connection.expects(:fields).with("CustomTable__c").returns(columns_hash)
    Salesforce.connection.expects(:find_object_by_id).with("CustomTable__c", "id", "Col1,Col2__c").returns("Col1" => 'col11', "Col2__c" => 'col21')
    result = Salesforce::CustomTable.find_by_id("id")
    assert_equal "col11", result.col1
    assert_equal "col21", result.col2
  end
  
  def test_find_all
    setup_columns_for_original_table
    Salesforce.connection.expects(:soql).with("SELECT Col1,Col2__c FROM OriginalTable").returns([ { "Col1" => 'col11', "Col2__c" => 'col21'}, { "Col1" => 'col21', "Col2__c" => 'col22'}])
    results =  Salesforce::OriginalTable.find(:all)
    assert_equal 2, results.size
    assert_equal "col11", results.first.col1
    assert_equal "col21", results.first.col2
    assert_equal "col21", results.last.col1
    assert_equal "col22", results.last.col2
  end
  def test_find_all__wrapped_by_with_invalid_column_handling
    Salesforce::OriginalTable.expects(:with_invalid_column_handling).returns(:find_all_result)
    
    assert_equal :find_all_result, Salesforce::OriginalTable.find_all
  end
  
  def test_find_all__with_select
    setup_columns_for_original_table
    Salesforce.connection.expects(:soql).with("SELECT Col2__c FROM OriginalTable").returns([ { "Col2__c" => 'col21'}, { "Col2__c" => 'col22'}])
    results =  Salesforce::OriginalTable.find(:all, :select => :col2)
    assert_equal 2, results.size
    assert_equal "col21", results.first.col2
    assert_equal "col22", results.last.col2
  end
  
  def test_find_all__with_conditions
    setup_columns_for_original_table
    Salesforce.connection.expects(:soql).with("SELECT Col1,Col2__c FROM OriginalTable WHERE Col2__c >= 2011-11-11").returns([ { "Col2__c" => 'col21'}, { "Col2__c" => 'col22'}])
    results =  Salesforce::OriginalTable.find(:all, :conditions => ":col2 >= :date", :date => Date.parse("2011-11-11"))
    assert_equal 2, results.size
    assert_equal "col21", results.first.col2
    assert_equal "col22", results.last.col2
  end
  
  def test_query_string
    Salesforce.connection.expects(:fields).with("OriginalTable").returns([ 
      { "name" => "Col1", "type" => "id" }, 
      {"name" => "Col2__c", "type" => "string"},
      {"name" => "Col3__c", "type" => "datetime"},
      {"name" => "ZCol4__c", "type" => "date"},
      {"name" => "ACol5__c", "type" => "boolean"}
    ])

    Salesforce::OriginalTable.columns
    
    assert_equal "SELECT ACol5__c,Col1,Col2__c,Col3__c,ZCol4__c FROM OriginalTable", Salesforce::OriginalTable.query_string({})
    assert_equal "SELECT ACol5__c FROM OriginalTable", Salesforce::OriginalTable.query_string({:select => :a_col5})
    assert_equal "SELECT ZCol4__c,Col2__c FROM OriginalTable", Salesforce::OriginalTable.query_string({:select => [ :z_col4, :col2 ]})
    
    assert_equal "SELECT ACol5__c FROM OriginalTable WHERE Col1 > Col2__c", Salesforce::OriginalTable.query_string(:select => :a_col5, :conditions => ":col1 > :col2")
    assert_equal "SELECT ACol5__c FROM OriginalTable WHERE Col1 > Col2__c", Salesforce::OriginalTable.query_string(:select => :a_col5, :conditions => ":col1 > :col2")
    assert_equal "SELECT ACol5__c FROM OriginalTable WHERE Col1 > 2011-08-01", Salesforce::OriginalTable.query_string(:select => :a_col5, :conditions => ":col1 > :date", 
                                                                                :date => Date.parse('2011-08-01') )
    assert_equal "SELECT ACol5__c FROM OriginalTable WHERE Col1 > 2011-08-01 AND ACol5__c = 2011-08-01T09:30:00-07:00", 
            Salesforce::OriginalTable.query_string(:select => :a_col5, 
                      :conditions => ":col1 > :date AND :a_col5 = :time", :date => Date.parse('2011-08-01'), :time => Time.zone.parse("2011-08-01 09:30 AM"))
    
    assert_equal "SELECT ACol5__c FROM OriginalTable WHERE Col1 = TRUE AND Col2__c = FALSE AND Col3__c = NULL", 
            Salesforce::OriginalTable.query_string(:select => :a_col5, 
                      :conditions => ":col1 = :true AND :col2 = :false AND :col3 = :nil", :true => true, :false => false, :nil => nil)
    
    assert_equal "SELECT ACol5__c FROM OriginalTable WHERE Col1 = 'string'", 
            Salesforce::OriginalTable.query_string(:select => :a_col5, :conditions => ":col1 = :string", :string => 'string' )
            
    assert_equal "SELECT ACol5__c FROM OriginalTable WHERE Col1 = 'string' ORDER BY Col1", 
            Salesforce::OriginalTable.query_string(:select => :a_col5, :conditions => ":col1 = :string", :string => 'string', :order => :col1)
            
    assert_equal "SELECT ACol5__c FROM OriginalTable WHERE Col1 = 'string' ORDER BY Col1 ASC, Col3__c DESC", 
            Salesforce::OriginalTable.query_string(:select => :a_col5, :conditions => ":col1 = :string", 
            :string => 'string' , :order => ":col1 ASC, :col3 DESC")
            
    assert_equal "SELECT ACol5__c FROM OriginalTable WHERE Col1 = 'string' GROUP BY Col2__c HAVING Col3__c > 2009-08-01 ORDER BY Col1 ASC, Col3__c DESC", 
            Salesforce::OriginalTable.query_string(:select => :a_col5, :conditions => ":col1 = :string", :group_by => :col2, :having => ":col3 > :date",
            :string => 'string', :date => Date.parse('2009-08-01'), :order => ":col1 ASC, :col3 DESC")
            
    
  
    assert_raises Salesforce::ColumnNotFound do
      Salesforce::OriginalTable.query_string({:select => [ :col4 ]})
    end
  end
  
  def test_find_all__columns_not_set
    columns_hash = [{"name" => "Col1", "type" => "id"}, { "name" => "Col2__c", "type" => "string" } ]
    columns      = columns_hash.map { |hash| Salesforce::Column.new(hash) }
    Salesforce.connection.expects(:fields).with("CustomTable__c").returns(columns_hash)
    Salesforce.connection.expects(:soql).with("SELECT Col1,Col2__c FROM CustomTable__c").returns([ { "Col1" => 'col11', "Col2__c" => 'col21'}, { "Col1" => 'col21', "Col2__c" => 'col22'} ])
    results =  Salesforce::CustomTable.find(:all)
    assert_equal 2, results.size
    assert_equal "col11", results.first.col1
    assert_equal "col21", results.first.col2
    assert_equal "col21", results.last.col1
    assert_equal "col22", results.last.col2
  end
  
  def test_dynamic_finders
    setup_columns_for_original_table
    
    Salesforce::OriginalTable.expects(:find_by_column).with do |col, value|
      col.original_name == "Col1" && value == "col1value"
    end.returns(:find_by_col1_result)

    assert_equal :find_by_col1_result, Salesforce::OriginalTable.find_by_col1("col1value")
    
    Salesforce::OriginalTable.expects(:find_by_column).with do |col, value|
      col.original_name == "Col2__c" && value == "col2value"
    end.returns(:find_by_col2_result)

    assert_equal :find_by_col2_result, Salesforce::OriginalTable.find_by_col2("col2value")
    
    Salesforce::OriginalTable.expects(:find_by_column).never

    assert_raises NoMethodError do
      Salesforce::OriginalTable.find_by_col3("col1value")
    end
  end
  
  def test_find_by_column
    setup_columns_for_original_table
    col = Salesforce::OriginalTable.columns.all.last
    Salesforce.connection.expects(:soql).with("SELECT Col1,Col2__c FROM OriginalTable WHERE #{col.original_name}='value'").returns([ { "Col1" => 'col11', "Col2__c" => 'col21'}, { "Col1" => 'col21', "Col2__c" => 'col22'} ])
    results =  Salesforce::OriginalTable.find_by_column(col, "value")
    assert_equal 2, results.size
    assert_equal "col11", results.first.col1
    assert_equal "col21", results.first.col2
    assert_equal "col21", results.last.col1
    assert_equal "col22", results.last.col2
  end
  
  def test_select_values
    setup_columns_for_original_table
    Salesforce::OriginalTable.expects(:query_string).with(:select => [ :col1, :col2 ], :other => :options).returns("sql_query")
    Salesforce.connection.expects(:soql).with("sql_query").returns([ { "Col1" => '123456789012345678', "Col2__c" => 'col21'}, { "Col1" => '123456789012345678', "Col2__c" => 'col22'} ])
    results = Salesforce::OriginalTable.select_values(:select => [ :col1, :col2 ], :other => :options)
    assert_equal 2, results.size
    assert_equal({ :col1 => '123456789012345', :col2 => 'col21'}, results.first)
    assert_equal({ :col1 => '123456789012345', :col2 => 'col22'}, results.last)
  end
  
  def test_with_invalid_column_handling__succeeds_the_first_time
    value = Salesforce::OriginalTable.with_invalid_column_handling do
      :foo
    end
    
    assert_equal :foo, value
  end
  
  def test_with_invalid_column_handling__throws_invalid_fields_error__more_than_once
    assert_raises Salesforce::InvalidRequest do
      Salesforce::OriginalTable.with_invalid_column_handling do
        raise Salesforce::InvalidRequest.new({ 'errorCode' => 'INVALID_FIELD'}, '/foo')
      end
    end
  end
  
  def test_with_invalid_column_handling__throws_invalid_fields_error__more_than_once
    error = RuntimeError.new
    Salesforce::OriginalTable.expects(:clear_cached_columns!).never
    
    assert_raises error.class do
      Salesforce::OriginalTable.with_invalid_column_handling do
        raise error
      end
    end
  end
  
  def test_with_invalid_column_handling__throws_invalid_fields_error__once__then_recovers
    count = 0 

    Salesforce::OriginalTable.expects(:clear_cached_columns!)
    value = Salesforce::OriginalTable.with_invalid_column_handling do
      if count < 1
        count += 1
        raise Salesforce::InvalidRequest.new({ 'errorCode' => 'INVALID_FIELD'}, '/foo') 
      end
      :bar
    end
    
    assert_equal :bar, value
  end
  
  private
  
  def clear_columns
    Salesforce::CustomTable.cached_columns   = nil
    Salesforce::OriginalTable.cached_columns = nil
  end
  
  def setup_columns_for_original_table
    Salesforce.connection.expects(:fields).with("OriginalTable").returns([ { "name" => "Col1", "type" => "id" }, {"name" => "Col2__c", "type" => "id"} ])
    Salesforce::OriginalTable.columns
  end
  
  def setup_columns_for_custom_table
    columns_hash = [ 
      { "name" => "Id", "type" => "id", "createable" => false, "updateable" => false}, 
      { "name" => "Account__c", "type" => "reference", "createable" => true, "updateable" => false, "custom" => true }, 
      { "name" => "Car__c", "type" => "reference", "createable" => false, "updateable" => true, "custom" => true},
      { "name" => "Name__c", "type" => "string", "createable" => true, "updateable" => true, "custom" => true} 
    ]
    
    Salesforce.connection.expects(:fields).with("CustomTable__c").returns(columns_hash).twice
    columns      = Salesforce::Columns.new("CustomTable__c")
    assert_equal columns, Salesforce::CustomTable.columns
  end
  
  
end
  
