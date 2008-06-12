require File.dirname(__FILE__) + '/../test_helper'

class JobTest < Test::Unit::TestCase
  fixtures :jobs, :users, :roles, :rights, :rights_roles

  def setup
  end

  def test_datatype
    assert_kind_of Job, jobs(:published_job)
    assert_kind_of Job, jobs(:unpublished_job)
  end
  
  def test_published_job
    assert jobs(:published_job).is_published?
  end

  def test_unpublished_job
    assert jobs(:unpublished_job).is_pending?
  end
  
  def test_publishing_date_unchanged_for_published_job
    published_at = jobs(:published_job).published_at
    jobs(:published_job).publish
    assert_equal published_at, jobs(:published_job).published_at
  end
  
  def test_unpublish_published_job
    assert_not_nil jobs(:published_job).published_at
    jobs(:published_job).unpublish
    assert_nil jobs(:published_job).published_at
  end

  def test_publish_unpublished_job
    assert_nil jobs(:unpublished_job).published_at
    jobs(:unpublished_job).publish
    assert_not_nil jobs(:published_job).published_at
    assert jobs(:published_job).published_at <= Time.now
  end
  
  def test_expired
    expired_jobs = Job.find_expired
    expired_jobs.each {|expired_job| assert expired_job.published_until < Time.now}
  end

  def test_current
    current_jobs = Job.find_current
    current_jobs.each {|current_job| assert current_job.published_until >= Time.now}
  end

end
