require File.dirname(__FILE__) + '/../test_helper'
require 'job_links_controller'

# Re-raise errors caught by the controller.
class JobLinksController; def rescue_action(e) raise e end; end

class JobLinksControllerTest < Test::Unit::TestCase
  fixtures :job_links, :users, :roles, :rights, :rights_roles

  def setup
    @controller = JobLinksController.new
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
      assert assigns(:job_links)
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
  
  def test_should_create_job_link
    @authorized_users.each do |user|
      login_as(user)
      old_count = JobLink.count
      create_job_link
      assert_equal old_count+1, JobLink.count
      current_user = User.find(session[:user])
      job_link = JobLink.find_by_title("JobLink Title")
      assert_equal current_user, job_link.author
      assert_equal current_user, job_link.last_editor
      assert_redirected_to job_links_path
      job_link.destroy
    end
  end

  def test_should_not_create_job_link
    @unauthorized_users.each do |user|
      login_as(user)
      old_count = JobLink.count
      create_job_link
      assert_access_denied
      assert_equal old_count, JobLink.count
    end
  end

  def test_should_show_job_link
    @authorized_users.each do |user|
      login_as(user)
      get :show, :id => 1
      assert_response :success
    end
  end

  def test_should_not_show_job_link
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
  
  def test_should_update_job_link
    @authorized_users.each do |user|
      login_as(user)
      author_before = job_links(:first).author
      last_editor_before = job_links(:first).last_editor
      put :update, :id => 1, :job_link => { "title" => "My new title"}
      my_job_link = JobLink.find_by_title("My new title")
      assert_equal author_before, my_job_link.author
      assert_equal users(user), my_job_link.last_editor
      assert_redirected_to job_links_path
    end
  end
  
  def test_should_not_update_job_link
    @unauthorized_users.each do |user|
      login_as(user)
      author_before = job_links(:second).author
      last_editor_before = job_links(:second).last_editor
      put :update, :id => 1, :job_link => { "title" => "My new title"}
      assert_access_denied
      my_job_link = JobEvent.find_by_title("My new title")
      assert_nil my_job_link
    end
  end
  
  def test_should_destroy_job_link
    @authorized_users.each_with_index do |user, index|
      login_as(user)
      old_count = JobLink.count
      delete :destroy, :id => index+1
      assert_equal old_count-1, JobLink.count
      assert_redirected_to job_links_path
    end
  end
  
  def test_should_not_destroy_job_link
    @unauthorized_users.each do |user|
      login_as(user)
      old_count = JobLink.count
      delete :destroy, :id => 1
      assert_access_denied
      assert_equal old_count, JobLink.count
    end
  end
  
  def test_should_move_first_job_link_down
    @authorized_users.each do |user|
      login_as(user)
      my_job_link = job_links(:first)
      assert_equal true, my_job_link.first?
      put :update, :id => my_job_link, :job_link => {:move_lower => true}
      assert_redirected_to job_links_path
      my_job_link.reload
      assert_equal false, my_job_link.first?
      my_job_link.move_higher
    end
  end
  
  def test_should_not_move_first_job_link_down
    @unauthorized_users.each do |user|
      login_as(user)
      my_job_link = job_links(:first)
      assert_equal true, my_job_link.first?
      put :update, :id => my_job_link, :job_link => {:move_lower => true}
      assert_access_denied
      my_job_link.reload
      assert_equal true, my_job_link.first?
    end
  end
  
  def test_should_move_last_job_link_up
    @authorized_users.each do |user|
      login_as(user)
      my_job_link = job_links(:third)
      assert_equal true, my_job_link.last?
      put :update, :id => my_job_link, :job_link => {:move_higher => true}
      assert_redirected_to job_links_path
      my_job_link.reload
      assert_equal false, my_job_link.last?
      my_job_link.move_lower
    end
  end
  
  def test_should_not_move_last_job_link_up
    @unauthorized_users.each do |user|
      login_as(user)
      my_job_link = job_links(:third)
      assert_equal true, my_job_link.last?
      put :update, :id => my_job_link, :job_link => {:move_higher => true}
      assert_access_denied
      my_job_link.reload
      assert_equal true, my_job_link.last?
    end
  end
  
  def test_should_move_second_job_link_first
    @authorized_users.each do |user|
      login_as(user)
      my_job_link = job_links(:second)
      assert_equal false, my_job_link.first?
      put :update, :id => my_job_link, :job_link => {:move_higher => true}
      assert_redirected_to job_links_path
      my_job_link.reload
      assert_equal true, my_job_link.first?
      my_job_link.move_lower
    end
  end
  
  def test_should_not_move_second_job_link_first
    @unauthorized_users.each do |user|
      login_as(user)
      my_job_link = job_links(:second)
      assert_equal false, my_job_link.first?
      put :update, :id => my_job_link, :job_link => {:move_higher => true}
      assert_access_denied
      my_job_link.reload
      assert_equal false, my_job_link.first?
    end
  end
  
  def test_should_move_second_job_link_last
    @authorized_users.each do |user|
      login_as(user)
      my_job_link = job_links(:second)
      assert_equal false, my_job_link.last?
      put :update, :id => my_job_link, :job_link => {:move_lower => true}
      assert_redirected_to job_links_path
      my_job_link.reload
      assert_equal true, my_job_link.last?
      my_job_link.move_higher
    end
  end
  
  def test_should_not_move_second_job_link_last
    @unauthorized_users.each do |user|
      login_as(user)
      my_job_link = job_links(:second)
      assert_equal false, my_job_link.last?
      put :update, :id => my_job_link, :job_link => {:move_lower => true}
      assert_access_denied
      my_job_link.reload
      assert_equal false, my_job_link.last?
    end
  end

  def test_should_show_public_list
    get :list
    assert_response :success
    assert assigns(:job_links)
  end
  
  protected
    def create_job_link(options = {})
      post :create, :job_link => {"title"=>"JobLink Title", "description"=>"Some description that makes a lot of sense.", "target"=>"http://mozilla.org"}.merge(options)
    end
end
