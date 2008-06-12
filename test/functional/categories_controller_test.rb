require File.dirname(__FILE__) + '/../test_helper'
require 'categories_controller'

# Re-raise errors caught by the controller.
class CategoriesController; def rescue_action(e) raise e end; end

class CategoriesControllerTest < Test::Unit::TestCase
  fixtures :categories, :users, :roles, :rights, :rights_roles

  def setup
    @controller = CategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    %w(index show new edit create update destroy).each {|action| Right.create(:name => "Categories", :controller => "categories", :action => action)}
    new_rights = Right.find_all_by_controller("categories")
    Role.find_by_name("admin").rights << new_rights
    login_as(:some_admin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:categories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_category
    old_count = Category.count
    post :create, :category => { }
    assert_equal old_count+1, Category.count
    
    assert_redirected_to category_path(assigns(:category))
  end

  def test_should_show_category
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_category
    put :update, :id => 1, :category => { }
    assert_redirected_to category_path(assigns(:category))
  end
  
  def test_should_destroy_sub_category
    old_count = Category.count
    delete :destroy, :id => 2
    assert_equal old_count-1, Category.count
    
    assert_redirected_to categories_path
  end

  def test_should_destroy_parent_category_and_sub_category
    old_count = Category.count
    number_of_children = Category.find(1).children.count
    delete :destroy, :id => 1
    assert_equal old_count-number_of_children-1, Category.count
    
    assert_redirected_to categories_path
  end
end
