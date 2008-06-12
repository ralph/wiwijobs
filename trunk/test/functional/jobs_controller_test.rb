require File.dirname(__FILE__) + '/../test_helper'
require 'jobs_controller'

# Re-raise errors caught by the controller.
class JobsController; def rescue_action(e) raise e end; end

class JobsControllerTest < Test::Unit::TestCase
  fixtures :jobs, :users, :roles, :rights, :rights_roles

  def setup
    @controller = JobsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as(:some_admin)
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:jobs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_unpublished_job
    old_count = Job.count
    create_unpublished_job
    assert_equal old_count+1, Job.count

    assert_redirected_to jobs_path
    user = User.find(session[:user])
    my_job = Job.find_by_place_and_title("Somewhere", "My unpublished Job")
    assert_equal false, my_job.is_published?
    assert_equal user, my_job.author
    assert_equal user, my_job.last_editor
  end

  def test_should_publish_unpublished_job
    create_unpublished_job
    my_job = Job.find_by_place_and_title("Somewhere", "My unpublished Job")
    put :update, :job => {:published => "1"}, :id => my_job
    assert_redirected_to jobs_path
    my_job.reload
    assert_equal true, my_job.is_published?
  end

  def test_should_create_published_job
    old_count = Job.count
    create_published_job
    assert_equal old_count+1, Job.count

    assert_redirected_to jobs_path
    user = User.find(session[:user])
    my_job = Job.find_by_place_and_title("Somewhere", "My published Job")
    assert_equal true, my_job.is_published?
    assert_equal user, my_job.author
    assert_equal user, my_job.last_editor
  end

  def test_should_create_unpublished_job_with_attachment
    old_count = Job.count
    create_unpublished_job_with_attachment
    assert_equal old_count+1, Job.count

    assert_redirected_to jobs_path
    user = User.find(session[:user])
    my_job = Job.find_by_place_and_title("Somewhere", "My unpublished Job")
    assert_equal false, my_job.is_published?
    assert_equal user, my_job.author
    assert_equal user, my_job.last_editor
    assert_equal my_job.attachment.filename, "heise.pdf"
  end

  def test_should_unpublish_published_job
    create_published_job
    my_job = Job.find_by_place_and_title("Somewhere", "My published Job")
    put :update, :job => {:published => "0"}, :id => my_job
    assert_redirected_to jobs_path
    my_job.reload
    assert_equal false, my_job.is_published?
  end

  def test_should_show_public_job
    logout
    get :show, :id => jobs(:published_job).id
    assert_response :success
    assert assigns(:job)
  end

  def test_should_show_public_list
    logout
    get :list
    assert_response :success
    assert assigns(:jobs)
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_job
    author_before = jobs(:published_job).author
    last_editor_before = jobs(:published_job).last_editor
    login_as(:some_job_admin)
    put :update, :id => jobs(:published_job).id, :job => { "title" => "My new title" }, :attachment => {"uploaded_data" => ""}
    my_job = Job.find_by_title("My new title")
    assert_equal author_before, my_job.author
    assert_equal users(:some_job_admin), my_job.last_editor
    assert_redirected_to jobs_path
  end

  def test_should_destroy_job
    old_count = Job.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Job.count

    assert_redirected_to jobs_path
  end

  def test_should_not_update_job_by_faculty
    login_as(:some_faculty_user)
    title_before = jobs(:published_job).title
    put :update, :id => 2, :job => { "title" => "My new title"}, :attachment => {"uploaded_data" => ""}
    my_job = Job.find(2)
    assert_equal my_job.title, title_before
  end

  def test_should_not_destroy_job_by_faculty
    login_as(:some_faculty_user)
    old_count = Job.count
    delete :destroy, :id => 1
    delete :destroy, :id => 2
    delete :destroy, :id => 3
    delete :destroy, :id => 5
    assert_equal old_count, Job.count
  end

  def test_should_destroy_job_by_faculty
    login_as(:some_faculty_user)
    old_count = Job.count
    delete :destroy, :id => 4
    assert_equal old_count-1, Job.count
    assert_redirected_to jobs_path
  end

  def test_should_not_destroy_job_by_company
    login_as(:some_company_user)
    old_count = Job.count
    delete :destroy, :id => 1
    delete :destroy, :id => 2
    delete :destroy, :id => 3
    delete :destroy, :id => 4
    assert_equal old_count, Job.count
  end

  def test_should_destroy_job_by_company
    login_as(:some_company_user)
    old_count = Job.count
    delete :destroy, :id => 5
    assert_equal old_count-1, Job.count
    assert_redirected_to jobs_path
  end

  def test_should_update_job_by_student
    login_as(:some_student)
    title_before = jobs(:student_job).title
    put :update, :id => jobs(:student_job).id, :job => { "title" => "My new title"}, :attachment => {"uploaded_data" => ""}
    assert_redirected_to jobs_path
    my_job = Job.find(jobs(:student_job).id)
    assert_equal "My new title", my_job.title
    assert_not_equal title_before, my_job.title
  end
  
  def test_everything_by_admin
    login_as(:some_admin)
    test_everything
  end

  def test_everything_by_job_admin
    login_as(:some_job_admin)
    test_everything
  end

  def test_everything_by_student
    login_as(:some_student)
    test_everything
  end

  def test_everything_by_faculty
    login_as(:some_faculty_user)
    test_everything
  end

  def test_everything_by_company
    login_as(:some_company_user)
    old_count = Job.count
    create_unpublished_job
    assert_equal old_count+1, Job.count
    assert_redirected_to jobs_path
    user = User.find(session[:user])
    my_job = Job.find_by_place_and_title("Somewhere", "My unpublished Job")
    assert_equal false, my_job.is_published?
    assert_equal user, my_job.author
    assert_equal user, my_job.last_editor
    # job was successfully created, now test if we can update it:
    put :update, :id => my_job.id, :job => { "title" => "My new title" }, :attachment => {"uploaded_data" => ""}
    my_job = Job.find_by_title("My new title")
    assert_equal user, my_job.author
    assert_equal user, my_job.last_editor
    assert_redirected_to jobs_path
    # job was successfully updated, now test if we can publish it (companies should not!):
    put :update, :job => {:published => "1"}, :id => my_job
    my_job.reload
    assert_equal false, my_job.is_published?
    # job was successfully published, now test if we can delete it:
    old_count = Job.count
    delete :destroy, :id => my_job.id
    assert_equal old_count-1, Job.count
    assert_redirected_to jobs_path
  end

  protected
  def test_everything
    old_count = Job.count
    create_unpublished_job
    assert_equal old_count+1, Job.count
    assert_redirected_to jobs_path
    user = User.find(session[:user])
    my_job = Job.find_by_place_and_title("Somewhere", "My unpublished Job")
    assert_equal false, my_job.is_published?
    assert_equal user, my_job.author
    assert_equal user, my_job.last_editor
    # job was successfully created, now test if we can update it:
    put :update, :id => my_job.id, :job => { "title" => "My new title" }, :attachment => {"uploaded_data" => ""}
    my_job = Job.find_by_title("My new title")
    assert_equal user, my_job.author
    assert_equal user, my_job.last_editor
    assert_redirected_to jobs_path
    # job was successfully updated, now test if we can publish it:
    put :update, :job => {:published => "1"}, :id => my_job
    my_job.reload
    assert_equal true, my_job.is_published?
    # job was successfully published, now test if we can delete it:
    old_count = Job.count
    delete :destroy, :id => my_job.id
    assert_equal old_count-1, Job.count
    assert_redirected_to jobs_path
  end
  
  def create_published_job(options = {})
    create_job(:published => "1", :title => "My published Job")
  end

  def create_unpublished_job(options = {})
    create_job(:published => "0", :title => "My unpublished Job")
  end

  def create_unpublished_job_with_attachment(options = {})
    post :create, :job => {:place => "Somewhere", "start_time(1i)" =>"2007", :contact_data => "Contact that guy in the suite.", "start_time(2i)"=>"2", :title => "My unpublished Job", :salary => "1", "start_time(3i)"=>"27", "published_until(1i)"=>"2020", "end_time(1i)"=>"2007", "end_time(2i)"=>"2", "published_until(2i)"=>"2", "published_until(3i)"=>"27", "end_time(3i)"=>"27", :description => "Some descriptive Text.", "published_until(4i)"=>"12", "published_until(5i)"=>"47", :qualification => "Somewhat better than dumbass", :published => "0", :company => "My great company"}.merge(options), :attachment =>  { :uploaded_data => fixture_file_upload('attachments/heise.pdf', 'application/pdf') }
  end
  
  def create_job(options = {})
    post :create, :job => {:place => "Somewhere", "start_time(1i)" =>"2007", :contact_data => "Contact that guy in the suite.", "start_time(2i)"=>"2", :title => "My unpublished Job", :salary => "1", "start_time(3i)"=>"27", "published_until(1i)"=>"2020", "end_time(1i)"=>"2007", "end_time(2i)"=>"2", "published_until(2i)"=>"2", "published_until(3i)"=>"27", "end_time(3i)"=>"27", :description => "Some descriptive Text.", "published_until(4i)"=>"12", "published_until(5i)"=>"47", :qualification => "Somewhat better than dumbass", :published => "0", :company => "My great company"}.merge(options), :attachment =>  { :uploaded_data => "" }
  end
end
