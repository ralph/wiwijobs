class CreateJobLinks < ActiveRecord::Migration
  def self.up
    create_table :job_links do |t|
      t.column :title, :string
      t.column :description, :text
      t.column :description_html, :text
      t.column :target, :string
      t.column :position, :integer
      t.column :author_id, :integer
      t.column :last_editor_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    %w(index show new edit create update destroy).each do |action|
      Right.create(:name => "Job Links", :controller => "job_links", :action => action)
    end
    new_rights = Right.find_all_by_controller("job_links")
    Role.find_by_name("admin").rights << new_rights
    Role.find_by_name("jobadmin").rights << new_rights
    Role.find_by_name("student").rights << new_rights
  end

  def self.down
    Right.find_all_by_controller("job_links").each {|right| right.destroy}
    drop_table :joblinks
  end
end
