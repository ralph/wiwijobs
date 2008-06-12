class AddRolesAndRightsTable < ActiveRecord::Migration
  def self.up    
    create_table :rights_roles, :id => false do |t|
      t.column "right_id", :integer
      t.column "role_id", :integer
    end
    admin_rights = []
    admin_rights << Right.find_all_by_controller("users")

    update_own_profile_rights = []
    update_own_profile_rights << Right.find_by_controller_and_action("users", "show")
    update_own_profile_rights << Right.find_by_controller_and_action("users", "edit")
    update_own_profile_rights << Right.find_by_controller_and_action("users", "update")
    update_own_profile_rights << Right.find_by_controller_and_action("users", "homepage")
    
    user_list_rights = []
    user_list_rights << Right.find_by_controller_and_action("users", "students")
    user_list_rights << Right.find_by_controller_and_action("users", "birthday_list")
    
    Role.find_by_name("admin").rights << admin_rights
    Role.find_by_name("jobadmin").rights << update_own_profile_rights << user_list_rights
    Role.find_by_name("student").rights << update_own_profile_rights << user_list_rights
    Role.find_by_name("faculty").rights << update_own_profile_rights
    Role.find_by_name("company").rights << update_own_profile_rights
  end

  def self.down
    drop_table :rights_roles
  end
end
