require File.dirname(__FILE__) + '/../test_helper'
require 'news_items_controller'

# Re-raise errors caught by the controller.
class NewsItemsController; def rescue_action(e) raise e end; end

class NewsItemsControllerTest < Test::Unit::TestCase
  fixtures :news_items, :users, :roles, :rights, :rights_roles

  def setup
    @controller = NewsItemsController.new
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
      assert assigns(:news_items)
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
  
  def test_should_create_news_item
    @authorized_users.each do |user|
      login_as(user)
      old_count = NewsItem.count
      create_news_item
      assert_equal old_count+1, NewsItem.count
      current_user = User.find(session[:user])
      news_item = NewsItem.find_by_title("Brand new News")
      assert_equal current_user, news_item.author
      assert_equal current_user, news_item.last_editor    
      assert_redirected_to news_items_path
      NewsItem.find_by_title("Brand new News").destroy
    end
  end
  
  def test_should_not_create_news_item
    @unauthorized_users.each do |user|
      login_as(user)
      old_count = NewsItem.count
      create_news_item
      assert_access_denied
      assert_equal old_count, NewsItem.count
    end
  end
  
  def test_should_show_news_item
    @authorized_users.each do |user|
      login_as(user)
      get :show, :id => 1
      assert_response :success
    end
  end

  def test_should_not_show_news_item
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
  
  def test_should_update_news_item
    @authorized_users.each do |user|
      login_as(user)
      author_before = news_items(:one).author
      last_editor_before = news_items(:one).last_editor
      put :update, :id => 1, :news_item => { "title" => "My new title"}
      my_news_item = NewsItem.find_by_title("My new title")
      assert_equal author_before, my_news_item.author
      assert_equal users(user), my_news_item.last_editor
      assert_redirected_to news_items_path
    end
  end
  
  def test_should_not_update_news_item
    @unauthorized_users.each do |user|
      login_as(user)
      author_before = news_items(:one).author
      last_editor_before = news_items(:one).last_editor
      put :update, :id => 1, :news_item => { "title" => "My new title"}
      assert_access_denied
      my_news_item = NewsItem.find_by_title("My new title")
      assert_nil my_news_item
    end
  end
  
  def test_should_destroy_news_item
    @authorized_users.each_with_index do |user, index|
      login_as(user)
      old_count = NewsItem.count
      delete :destroy, :id => index+1
      assert_equal old_count-1, NewsItem.count
      assert_redirected_to news_items_path
    end
  end
  
  def test_should_not_destroy_news_item
    @unauthorized_users.each do |user|
      login_as(user)
      old_count = NewsItem.count
      delete :destroy, :id => 1
      assert_access_denied
      assert_equal old_count, NewsItem.count
    end
  end
  
  protected
    def create_news_item(options = {})
      post :create, :news_item => {"title"=>"Brand new News", "text"=>"This is some very descriptive News Text. Go and read it! Don't miss a line!", "published_until(1i)"=>"2007", "published_until(2i)"=>"2", "published_until(3i)"=>"25", "published_at(1i)"=>"2007", "published_until(4i)"=>"16", "published_at(2i)"=>"2", "published_at(3i)"=>"25", "published_until(5i)"=>"02", "published_at(4i)"=>"13", "published_at(5i)"=>"02"}
    end
end
