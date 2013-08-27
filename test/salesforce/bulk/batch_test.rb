require 'test_helper'

class Salesforce::Bulk::BatchTest < ActiveSupport::TestCase
  setup :clear_columns_for_bulk_table
  setup :setup_columns_for_bulk_table
  setup :setup_job
  teardown :clear_file
  
  def test_initialize
    assert_equal @job, @batch.job
    assert !@batch.filename.nil?
    assert !@batch.csv.nil?
    @batch.csv.close
    content = File.read(@batch.filename)
    assert_equal "Id,Name__c,dob__c,Car__c".split(",").sort, content.strip.split(",").sort
    assert_equal [ 'Id', "Name__c", "dob__c", "Car__c"].sort, @batch.send(:csv_header).sort
  end
  
  def test_record__from_hash
    @batch.expects(:ordered_values).with(anything).returns([ 'recordid', 'record name', "2008-10-14", 'record car'])
    @batch.csv.expects(:<<).with([ 'recordid', 'record name', "2008-10-14", 'record car'])
    @batch.record :id => "recordid", :name => "record name", :car => "record car", :dob => Date.parse("2008-10-14")

    @batch.expects(:ordered_values).with(anything).returns([ 'recordid', 'record name', "2008-10-14", 'record car'])    
    @batch.csv.expects(:<<).with([ 'recordid', 'record name', "2008-10-14", 'record car'])
    @batch.record :id => "recordid", :name => "record name", :car => "record car", :dob => "10/14/2008"

    @batch.expects(:ordered_values).with(anything).returns([ 'recordid', '', '', 'record car'])        
    @batch.csv.expects(:<<).with([ 'recordid', '', '', 'record car'])
    @batch.record :id => "recordid", :car => "record car"
    
    @batch.expects(:ordered_values).with(anything).returns([ 'recordid', '', '', ''])        
    @batch.csv.expects(:<<).with([ 'recordid', '', '', ''])
    @batch.record :id => "recordid"
  end
  
  def test_record__from_object
    bulk_table = Salesforce::BulkTable.new("Id" => "btid", :name => "name", "Car__c" => 'car', :dob => "10/14/2008")
    @batch.expects(:ordered_values).with(anything).returns(['btid', "name", "2008-10-14", "car"])
    @batch.csv.expects(:<<).with(['btid', "name", "2008-10-14", "car"])
    @batch.record bulk_table
  end
  
  def test_create
    @batch.csv.expects(:close)
    File.expects(:read).returns("csv_contents")
    Salesforce.connection.expects(:async_post).with("job/#{@job.id}/batch", "csv_contents", :format => :xml, :content_type => "text/csv").returns("id" => "batchid", "state" => "In Progress")
    @batch.create!
    assert_equal "batchid", @batch.id
    assert @batch.in_progress?
  end
  
  def test_update_status
    Salesforce.connection.expects(:async_get).with("job/#{@job.id}/batch/#{@batch.id}", :format => :xml).returns(:state => "Not Processed")
    @batch.update_status
    assert @batch.not_processed?
    
    Salesforce.connection.expects(:async_get).with("job/#{@job.id}/batch/#{@batch.id}", :format => :xml).returns(:state => "Completed")
    @batch.update_status
    assert @batch.completed?
    
    Salesforce.connection.expects(:async_get).never
    @batch.update_status
  end
  
  def test_results
    csv = "Id,Success,Created,Errors\n1,true,no,\n2,true,yes,"
    Salesforce.connection.expects(:async_get).with("job/#{@job.id}/batch/#{@batch.id}/result").returns(csv)
    assert_equal 2, @batch.results.size
  end
  
  private
  
  def setup_job
    @job = Salesforce::Bulk::UpdateJob.new(Salesforce::BulkTable)
    @batch = @job.batch do
    end
  end
  
  def clear_file
    FileUtils.rm_rf(@batch.filename) if @batch.filename.present?
  end
end
  
