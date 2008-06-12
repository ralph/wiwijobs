class AddAuxiliaryRights < ActiveRecord::Migration
  def self.up
    textilize_right = Right.create(:name => "Textilize", :controller => "auxiliary", :action => "textilize")
    %w(admin jobadmin student faculty company).each do |role_name|
      Role.find_by_name(role_name).rights << textilize_right      
    end
  end

  def self.down
    Right.destroy_all(:controller => "auxiliary", :action => "textilize")
  end
end
