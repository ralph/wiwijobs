require File.dirname(__FILE__) + '/../test_helper'
require 'rights_controller'

# Re-raise errors caught by the controller.
class RightsController; def rescue_action(e) raise e end; end

class RightsControllerTest < Test::Unit::TestCase
  fixtures :rights, :users, :roles, :rights_roles

  def setup
    @controller = RightsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    %w(index show new edit create update destroy).each {|action| Right.create(:name => "Rights", :controller => "rights", :action => action)}
    new_rights = Right.find_all_by_controller("rights")
    Role.find_by_name("admin").rights << new_rights
    login_as (:some_admin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:rights)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_right
    old_count = Right.count
    post :create, :right => { "name" => "Some Name", "controller" => "mycontroller", "action" => "myaction" }
    assert_equal old_count+1, Right.count
    
    assert_redirected_to right_path(assigns(:right))
  end

  def test_should_show_right
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_right
    put :update, :id => 1, :right => { }
    assert_redirected_to right_path(assigns(:right))
  end
  
  def test_should_destroy_right
    old_count = Right.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Right.count
    
    assert_redirected_to rights_path
  end
end
