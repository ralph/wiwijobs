require File.dirname(__FILE__) + '/../test_helper'

class JobEventTest < Test::Unit::TestCase
  fixtures :job_events

  def setup
    # @my_user = users(:some_admin)
  end

  def test_datatype
    assert_kind_of JobEvent, job_events(:current_job_event)
    assert_kind_of JobEvent, job_events(:expired_job_event)
  end
  
  def test_expired
    expired_job_events = JobEvent.find_expired
    expired_job_events.each {|expired_job_event| assert expired_job_event.time <= Time.now}
  end

  def test_current
    current_job_events = JobEvent.find_current
    current_job_events.each {|current_job_event| assert current_job_event.time > Time.now}
  end
end
