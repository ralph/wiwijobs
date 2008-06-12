class CreateUserRights < ActiveRecord::Migration
  def self.up
    create_table :rights do |t|
      t.column :name, :string
      t.column :controller, :string
      t.column :action, :string
    end
    %w(index show new edit create update destroy update_user_type_specific_fields update_all destroy_all students birthday_list homepage).each do |action|
      Right.create(:name => "Benutzer", :controller => "users", :action => action)
    end
  end

  def self.down
    drop_table :rights
  end
end
