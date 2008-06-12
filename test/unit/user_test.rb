require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  fixtures :users

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    users(:some_admin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:some_admin), User.authenticate('some_admin', 'new password')
  end

  def test_should_not_rehash_password
    users(:some_admin).update_attributes(:login => 'admin2')
    assert_equal users(:some_admin), User.authenticate('admin2', 'password')
  end

  def test_should_authenticate_user
    assert_equal users(:some_admin), User.authenticate('some_admin', 'password')
  end

  def test_should_set_remember_token
    users(:some_admin).remember_me
    assert_not_nil users(:some_admin).remember_token
    assert_not_nil users(:some_admin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:some_admin).remember_me
    assert_not_nil users(:some_admin).remember_token
    users(:some_admin).forget_me
    assert_nil users(:some_admin).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    users(:some_admin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:some_admin).remember_token
    assert_not_nil users(:some_admin).remember_token_expires_at
    assert users(:some_admin).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    users(:some_admin).remember_me_until time
    assert_not_nil users(:some_admin).remember_token
    assert_not_nil users(:some_admin).remember_token_expires_at
    assert_equal users(:some_admin).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    users(:some_admin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:some_admin).remember_token
    assert_not_nil users(:some_admin).remember_token_expires_at
    assert users(:some_admin).remember_token_expires_at.between?(before, after)
  end
  
  def test_should_reset_password
    previous_password = users(:some_student).password
    users(:some_student).reset_password
    assert_not_equal previous_password, users(:some_student).password
  end

  def test_should_get_vcard
    users(:some_student).to_vcard
  end
  
  def test_student_full_name
    student = Student.new(:first_name => "Heinz", :last_name => "Schmidt", :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire')
    assert_equal("Heinz Schmidt", student.name)
  end

  def test_faculty_institution_name
    faculty = Faculty.new(:institution_name => "Wiwi irgendwas", :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire')
    assert_equal("Wiwi irgendwas", faculty.name)
  end
  
  def test_company_institution_name
    company = Company.new(:institution_name => "Firma irgendwas", :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire')
    assert_equal("Firma irgendwas", company.name)
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
