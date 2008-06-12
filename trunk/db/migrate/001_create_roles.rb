class CreateRoles < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      # Der Name dient systemintern zum referenzieren und darf daher nicht verändert werden.
      # Der Titel soll öffentlich sichtbar und editierbar sein.
      t.column :name, :string
      t.column :title, :string
    end
    Role.create(:name => "admin", :title => "Administrator")
    Role.create(:name => "jobadmin", :title => "Jobbörse Administrator")
    Role.create(:name => "student", :title => "Fachschaftler")
    Role.create(:name => "faculty", :title => "Fakultät")
    Role.create(:name => "company", :title => "Unternehmensbenutzer")
  end

  def self.down
    remove_column :users, :role
    drop_table :roles
  end
end
