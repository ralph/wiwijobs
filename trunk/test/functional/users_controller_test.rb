# Zu diesem Test gibt es weitere Hinweise im sessions_controller_test.rb

require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase

  fixtures :users, :roles, :rights, :rights_roles

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as (:some_admin)
  end

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end
  
  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_should_activate_user
    assert_nil User.authenticate('some_student', 'password')
    get :activate, :activation_code => users(:some_student).activation_code
    assert_redirected_to admin_url
    assert_not_nil flash[:notice]
    assert_equal users(:some_student), User.authenticate('some_student', 'password')
  end

  def test_should_reset_password
    create_user
    previous_crypted_password = User.find_by_login("quire").crypted_password
    get :activate, :activation_code => User.find_by_login("quire").activation_code
    post :reset_password, :email => 'quire@example.com'
    assert_not_equal previous_crypted_password, User.find_by_login("quire").crypted_password
    assert_nil User.authenticate('quire', 'quire')
  end

  def test_job_admin_should_get_students
    login_as(:some_job_admin)
    get :students
    assert_response :success
    assert assigns(:users)
  end

  def test_student_should_get_students
    login_as(:some_student)
    get :students
    assert_response :success
    assert assigns(:users)
  end

  def test_company_should_not_get_index
    login_as(:some_company_user)
    get :index
    assert_response 302
  end

  def test_faculty_should_not_get_index
    login_as(:some_faculty_user)
    get :index
    assert_response 302
  end

  def test_admin_should_update_self
    who = :some_admin
    login_as(who)
    test_someone_should_update_self(users(who))
  end

  def test_job_admin_should_update_self
    who = :some_job_admin
    login_as(who)
    test_someone_should_update_self(users(who))
  end

  def test_student_should_update_self
    who = :some_student
    login_as(who)
    test_someone_should_update_self(users(who))
  end

  def test_faculty_should_update_self
    who = :some_faculty_user
    login_as(who)
    test_someone_should_update_self(users(who))
  end

  def test_company_should_update_self
    who = :some_company_user
    login_as(who)
    test_someone_should_update_self(users(who))
  end

  def test_admin_should_update_others
    login_as(:some_admin)
    user = users(:some_other_student)
    put :update, :id => user.id, :user => { "street" => "My long long street" }
    assert_redirected_to user_path(assigns(:user))
    user = User.find_by_street("My long long street")
    assert_not_nil user
  end

  def test_job_admin_should_not_update_others
    login_as(:some_job_admin)
    test_someone_should_not_update_others
  end

  def test_student_should_not_update_others
    login_as(:some_student)
    test_someone_should_not_update_others
  end

  def test_faculty_should_not_update_others
    login_as(:some_faculty_user)
    test_someone_should_not_update_others
  end

  def test_company_should_not_update_others
    login_as(:some_company_user)
    test_someone_should_not_update_others
  end

  def test_student_should_not_update_own_role
    login_as(:some_student)
    previous_role = users(:some_student).role
    put :update, :id => users(:some_student).id, :user => { "role_id" => "1" }
    user = User.find(users(:some_student).id)
    assert_equal previous_role, user.role
  end

  def test_admin_should_update_role
    login_as(:some_admin)
    previous_role = users(:some_student).role
    put :update, :id => users(:some_student).id, :user => { "role_id" => "1" }
    user = User.find(users(:some_student).id)
    assert_not_equal previous_role, user.role
    assert_equal 1, user.role.id
  end
  
  def test_uploading_invalid_avatar_should_not_delete_old_avatar
    @valid_file = ActionController::TestUploadedFile.new(RAILS_ROOT + '/test/fixtures/avatars/rails.png', 'image/png')
    user = users(:some_admin)
    put :update, :id => user.id, :user => {}, :avatar =>  { :uploaded_data => @valid_file }
    user.reload
    assert_equal "rails.png", user.avatar.filename
    @invalid_file = ActionController::TestUploadedFile.new(RAILS_ROOT + '/test/fixtures/attachments/google.pdf', 'application/pdf')
    put :update, :id => user.id, :user => {}, :avatar =>  { :uploaded_data => @invalid_file }
    user.reload
    assert_equal "rails.png", user.avatar.filename  
  end
  
  def test_someone_should_update_own_password
    user = users(:some_admin)
    crypted_password_before = user.crypted_password
    put :update, :id => user.id, :user => { :password => 'neuespw', :password_confirmation => 'neuespw' }
    user.reload
    assert_not_equal crypted_password_before, user.crypted_password
    assert_equal users(:some_admin), User.authenticate('some_admin', 'neuespw')
  end
  
  protected
  def test_someone_should_not_update_others
    user = users(:some_other_student)
    put :update, :id => user.id, :user => { "street" => "My long long street" }
    assert_response 302
    user = User.find_by_street("My long long street")
    assert_nil user
  end
  
  def test_someone_should_update_self(user)
    put :update, :id => user.id, :user => { "street" => "My long long street" }
    assert_redirected_to user_path(assigns(:user))
    updated_user = User.find_by_street("My long long street")
    assert_equal updated_user, user
    assert_equal "My long long street", updated_user.street
  end
    
  def create_user(options = {})
    post :create, :user => { :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire', :first_name => "quire", :last_name => "example", :role_id => "3" }.merge(options), :activate => {"checked"=>"0"}, :type => {"type" => "Student"}, :avatar => {"uploaded_data" => ""}
  end
end
