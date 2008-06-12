require File.dirname(__FILE__) + '/../test_helper'
require 'job_events_controller'

# Re-raise errors caught by the controller.
class JobEventsController; def rescue_action(e) raise e end; end

class JobEventsControllerTest < Test::Unit::TestCase
  fixtures :job_events, :users, :roles, :rights, :rights_roles

  def setup
    @controller = JobEventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @authorized_users = [:some_admin, :some_job_admin, :some_student]
    @unauthorized_users = [:some_faculty_user, :some_company_user]
  end

  def test_should_get_index
    @authorized_users.each do |user|
      login_as(user)
      get :index
      assert_response :success
      assert assigns(:job_events)
    end
  end
  
  def test_should_not_get_index
    @unauthorized_users.each do |user|
      login_as(user)
      get :index
      assert_access_denied
    end
  end
  
  def test_should_get_new
    @authorized_users.each do |user|
      login_as(user)
      get :new
      assert_response :success
    end
  end
  
  def test_should_not_get_new
    @unauthorized_users.each do |user|
      login_as(user)
      get :new
      assert_access_denied
    end
  end
  
  def test_should_create_job_event
    @authorized_users.each do |user|
      login_as(user)
      old_count = JobEvent.count
      create_job_event
      assert_equal old_count+1, JobEvent.count
      current_user = User.find(session[:user])
      job_event = JobEvent.find_by_title("Some interesting event")
      assert_equal current_user, job_event.author
      assert_equal current_user, job_event.last_editor    
      assert_redirected_to job_events_path
      JobEvent.find_by_title("Some interesting event").destroy
    end
  end
  
  def test_should_not_create_job_event
    @unauthorized_users.each do |user|
      login_as(user)
      old_count = JobEvent.count
      create_job_event
      assert_access_denied
      assert_equal old_count, JobEvent.count
    end
  end

  def test_should_show_job_event
    @authorized_users.each do |user|
      login_as(user)
      get :show, :id => 1
      assert_response :success
    end
  end

  def test_should_not_show_job_event
    @unauthorized_users.each do |user|
      login_as(user)
      get :show, :id => 1
      assert_access_denied
    end
  end

  def test_should_get_edit
    @authorized_users.each do |user|
      login_as(user)
      get :edit, :id => 1
      assert_response :success
    end
  end
  
  def test_should_not_get_edit
    @unauthorized_users.each do |user|
      login_as(user)
      get :edit, :id => 1
      assert_access_denied
    end
  end

  def test_should_update_job_event
    @authorized_users.each do |user|
      login_as(user)
      author_before = job_events(:current_job_event).author
      last_editor_before = job_events(:current_job_event).last_editor
      put :update, :id => 1, :job_event => { "title" => "My new title"}
      my_job_event = JobEvent.find_by_title("My new title")
      assert_equal author_before, my_job_event.author
      assert_equal users(user), my_job_event.last_editor
      assert_redirected_to job_events_path
    end
  end
  
  def test_should_not_update_job_event
    @unauthorized_users.each do |user|
      login_as(user)
      author_before = job_events(:current_job_event).author
      last_editor_before = job_events(:current_job_event).last_editor
      put :update, :id => 1, :job_event => { "title" => "My new title"}
      assert_access_denied
      my_job_event = JobEvent.find_by_title("My new title")
      assert_nil my_job_event
    end
  end
  
  def test_should_destroy_job_event
    @authorized_users.each_with_index do |user, index|
      login_as(user)
      old_count = JobEvent.count
      delete :destroy, :id => index+1
      assert_equal old_count-1, JobEvent.count
      assert_redirected_to job_events_path
    end
  end
  
  def test_should_not_destroy_job_event
    @unauthorized_users.each do |user|
      login_as(user)
      old_count = JobEvent.count
      delete :destroy, :id => 1
      assert_equal old_count, JobEvent.count
      assert_access_denied
    end
  end

  def test_should_show_public_list
    get :list
    assert_response :success
    assert assigns(:job_events)
  end
  
  protected
    def create_job_event(options = {})
      post :create, :job_event => {"place"=>"Some place near you", "time(1i)"=>"2007", "time(2i)"=>"2", "closing_date_for_applications(1i)"=>"2007", "title"=>"Some interesting event", "time(3i)"=>"21", "time(4i)"=>"18", "closing_date_for_applications(2i)"=>"2", "closing_date_for_applications(3i)"=>"21", "time(5i)"=>"14", "closing_date_for_applications(4i)"=>"18", "closing_date_for_applications(5i)"=>"14", "description"=>"This is an event you must not miss!"}.merge(options), :attachment => {"uploaded_data" => ""}
    end
end
