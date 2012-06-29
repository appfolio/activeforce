require 'test_helper'

class Salesforce::Bulk::UpdateJobTest < ActiveSupport::TestCase
  
  setup :setup_columns_for_bulk_table
  setup :setup_columns_for_account
  

  def test_initialize
    job = Salesforce::Bulk::UpdateJob.new(Salesforce::Account)
    assert_equal Salesforce::Account, job.object_type
    assert_equal 'update', job.operation
    assert_equal 'Parallel', job.concurrency_mode
    assert_equal 'Account', job.object
    assert_equal 'Id,City,Address,Name,Type,State', job.send(:csv_header).join(',')
  end
  
  def test_initialize__with_columns
    job = Salesforce::Bulk::UpdateJob.new(Salesforce::Account, [:name, :state]) 
    assert_equal Salesforce::Account, job.object_type
    assert_equal 'update', job.operation
    assert_equal 'Parallel', job.concurrency_mode
    assert_equal 'Account', job.object
    assert_equal 'Id,Name,State', job.send(:csv_header).join(',')
  end
  
  def test_initialize__with_all
    job = Salesforce::Bulk::UpdateJob.new(Salesforce::Account, :all)
    assert_equal Salesforce::Account, job.object_type
    assert_equal 'update', job.operation
    assert_equal 'Parallel', job.concurrency_mode
    assert_equal 'Account', job.object
    assert_equal 'Id,City,Address,Name,Type,State', job.send(:csv_header).join(',')
  end
  
  def test_csv_columns__unrecognized_column
    assert_raises Salesforce::UnrecognizedColumn do
      Salesforce::Bulk::UpdateJob.new(Salesforce::Account, [ :ssn ]).csv_columns
    end
  end
  
  def test_bulk_update
    Salesforce::Bulk::UpdateJob.any_instance.expects(:process!)
    
    job = Salesforce::BulkTable.bulk_update do
      serial!
      batch do
        record({})
        record({})
      end
    end
    
    assert_equal Salesforce::BulkTable, job.object_type
    assert_equal 'update', job.operation
    assert_equal 'Serial', job.concurrency_mode
    assert_equal 'BulkTable__c', job.object
    assert_equal 1, job.batches.size
  end
  
  def test_process
    job = Salesforce::Bulk::UpdateJob.new(Salesforce::Account)
    job.expects(:create_job!)
    job.expects(:create_batches!)
    job.expects(:close_job!)
    job.process!
  end
  
  def test_create_job
    job = Salesforce::Bulk::UpdateJob.new(Salesforce::Account)
    xml = anything
    Salesforce.connection.expects(:async_post).with("job", xml, :format => :xml).returns({ "id" => 3})
    job.send :create_job!
    assert_equal 3, job.id
  end
  
  def test_completed
    job_with_batches
    @batch_1.stubs(:update_status)
    @batch_2.stubs(:update_status)
    @batch_1.expects(:completed?).returns(false)
    @batch_1.expects(:failed?).returns(false)
    assert_equal false, @job.completed?

    @batch_1.expects(:completed?).returns(true)
    @batch_2.expects(:completed?).returns(false)
    @batch_2.expects(:failed?).returns(false)
    assert_equal false, @job.completed?

    @batch_1.expects(:completed?).returns(true)
    @batch_2.expects(:completed?).returns(false)
    @batch_2.expects(:failed?).returns(true)
    assert @job.completed?
  end
  
  def test_results
    job_with_batches
    @batch_1.expects(:results).returns([ :result_1, :result_2])
    @batch_2.expects(:results).returns([ :result_3, :result_4])
    assert_equal [ :result_1, :result_2, :result_3, :result_4 ], @job.results
  end
  
  def test_close_job
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    job_with_batches
    Salesforce.connection.expects(:async_post).with("job/jobId", includes("<state>Closed</state>"), :format => :xml).returns("state" => "Closed", "number_batches_total" => 2)
    @job.send(:close_job!)
    assert_equal 2, @job.number_batches_total
    assert @job.closed?
  end
  
  private
  
  def job_with_batches
    Salesforce::Authentication.stubs(:session_id).returns('session_id')
    
    @job = Salesforce::Bulk::UpdateJob.new(Salesforce::Account)
    @job.id = "jobId"
    @batch_1 = Salesforce::Bulk::Batch.new(@job)
    @batch_2 = Salesforce::Bulk::Batch.new(@job)
    @job.batches << @batch_1
    @job.batches << @batch_2
  end
    
  
end