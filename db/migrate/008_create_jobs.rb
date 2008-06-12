class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.column :title, :string
      t.column :description, :text
      t.column :description_html, :text
      t.column :company, :text
      t.column :contact_data, :text
      t.column :contact_data_html, :text
      t.column :published_at, :datetime
      t.column :published_until, :datetime
      t.column :place, :string
      t.column :qualification, :string
      t.column :salary, :boolean
      t.column :start_time, :date
      t.column :end_time, :date
      t.column :author_id, :integer
      t.column :last_editor_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    %w(index show new edit create update destroy publish unpublish update_all destroy_all publish_all unpublish_all).each do |action|
      Right.create(:name => "Jobs", :controller => "jobs", :action => action)
    end
    
    admin_rights = Right.find_all_by_controller("jobs")
    
    faculty_rights = []
    faculty_rights << Right.find_by_controller_and_action("jobs", "index")
    faculty_rights << Right.find_by_controller_and_action("jobs", "show")
    faculty_rights << Right.find_by_controller_and_action("jobs", "new")
    faculty_rights << Right.find_by_controller_and_action("jobs", "edit")
    faculty_rights << Right.find_by_controller_and_action("jobs", "create")
    faculty_rights << Right.find_by_controller_and_action("jobs", "update")
    faculty_rights << Right.find_by_controller_and_action("jobs", "destroy")
    faculty_rights << Right.find_by_controller_and_action("jobs", "publish")
    faculty_rights << Right.find_by_controller_and_action("jobs", "unpublish")
    
    Role.find_by_name("admin").rights << admin_rights
    Role.find_by_name("jobadmin").rights << admin_rights
    Role.find_by_name("student").rights << admin_rights
    Role.find_by_name("faculty").rights << faculty_rights
    
    company_rights = faculty_rights - [Right.find_by_controller_and_action("jobs", "publish")]
    Role.find_by_name("company").rights << company_rights
  end

  def self.down
    Right.find_all_by_controller("jobs").each {|right| right.destroy}
    drop_table :jobs
  end
end
