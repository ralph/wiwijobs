class CreateJobEvents < ActiveRecord::Migration
  def self.up
    create_table :job_events do |t|
      t.column :title, :string
      t.column :description, :text
      t.column :description_html, :text
      t.column :place, :string
      t.column :time, :datetime
      t.column :closing_date_for_applications, :datetime
      t.column :author_id, :integer
      t.column :last_editor_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end

    %w(index show new edit create update destroy).each do |action|
      Right.create(:name => "Job Events", :controller => "job_events", :action => action)
    end

    new_rights = Right.find_all_by_controller("job_events")
    Role.find_by_name("admin").rights << new_rights
    Role.find_by_name("jobadmin").rights << new_rights
    Role.find_by_name("student").rights << new_rights
  end

  def self.down
    Right.find_all_by_controller("job_events").each {|right| right.destroy}
    drop_table :job_events
  end
end
