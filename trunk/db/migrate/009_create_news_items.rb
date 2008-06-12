class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.column :title, :string
      t.column :text, :text
      t.column :text_html, :text
      t.column :published_at, :datetime
      t.column :published_until, :datetime
      t.column :author_id, :integer
      t.column :last_editor_id, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    
    %w(index show new edit create update destroy internal job list).each do |action|
      Right.create(:name => "News", :controller => "news_items", :action => action)
    end
    
    new_rights = Right.find_all_by_controller("news_items")
    
    Role.find_by_name("admin").rights << new_rights
    Role.find_by_name("jobadmin").rights << new_rights
    Role.find_by_name("student").rights << new_rights
    Role.find_by_name("faculty").rights << Right.find_by_controller_and_action("news_items", "job")
    Role.find_by_name("company").rights << Right.find_by_controller_and_action("news_items", "job")
  end

  def self.down
    Right.find_all_by_controller("news_items").each {|right| right.destroy}
    drop_table :news_items
  end
end
