class AddUserTypesAttributes < ActiveRecord::Migration
  def self.up
    # applicable to all types of users
    add_column :users, :street, :string
    add_column :users, :zip, :integer
    add_column :users, :city, :string
    add_column :users, :phone, :string
    add_column :users, :homepage, :string


    # applicable to students only
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :home_street, :string
    add_column :users, :home_zip, :integer
    add_column :users, :home_city, :string
    add_column :users, :home_phone, :string
    add_column :users, :mobile, :string
    add_column :users, :icq, :integer
    add_column :users, :birthday, :date
    add_column :users, :application_date, :date
    add_column :users, :opt_out_date, :datetime
    add_column :users, :key_fs, :integer
    add_column :users, :key_wi, :integer
    add_column :users, :study_course, :string
    add_column :users, :wi_ag_member, :boolean

    # applicable to faculties only
    # <nothing here yet>
    
    # applicable to companies only
    # <nothing here yet>

    # applicable to companies and faculties only
    add_column :users, :institution_name, :string
    add_column :users, :contact_person_name, :string
    
    Student.create(:login => 'some_admin', :email => 'ralph@rvdh.de', :password => 'password', :password_confirmation => 'password', :role => Role.find_by_name("admin"), :first_name => "Super", :last_name => "Admin", :study_course => "BWL").activate
    Student.create(:login => 'some_job_admin', :email => 'ralf@rvdh.de', :password => 'password', :password_confirmation => 'password', :role => Role.find_by_name("jobadmin"), :first_name => "Job", :last_name => "Admin", :study_course => "BWL").activate
    Student.create(:login => 'some_student', :email => 'ralph@rvdh.net', :password => 'password', :password_confirmation => 'password', :role => Role.find_by_name("student"), :first_name => "Normaler", :last_name => "Fachschaftler", :study_course => "BWL").activate
    Faculty.create(:login => 'some_faculty_user', :email => 'ralph@rvdh.org', :password => 'password', :password_confirmation => 'password', :role => Role.find_by_name("faculty"), :institution_name => "Eine Fakultät").activate
    Company.create(:login => 'some_company_user', :email => 'ralph@firedesign.de', :password => 'password', :password_confirmation => 'password', :role => Role.find_by_name("company"), :institution_name => "Ein Unternehmen").activate
    
  end

  def self.down
    User.find_by_login("some_admin").destroy
    User.find_by_login("some_job_admin").destroy
    User.find_by_login("some_student").destroy
    User.find_by_login("some_faculty_user").destroy
    User.find_by_login("some_company_user").destroy
    remove_column :users, :street
    remove_column :users, :zip
    remove_column :users, :city
    remove_column :users, :phone
    remove_column :users, :homepage
    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :home_street
    remove_column :users, :home_zip
    remove_column :users, :home_city
    remove_column :users, :home_phone
    remove_column :users, :mobile
    remove_column :users, :icq
    remove_column :users, :birthday
    remove_column :users, :application_date
    remove_column :users, :opt_out_date
    remove_column :users, :key_fs
    remove_column :users, :key_wi
    remove_column :users, :study_course
    remove_column :users, :wi_ag_member
    remove_column :users, :institution_name
    remove_column :users, :contact_person_name
  end
end
