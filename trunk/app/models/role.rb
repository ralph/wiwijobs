class Role < ActiveRecord::Base
  has_and_belongs_to_many :rights
  has_many :users
  validates_presence_of :name, :title
  
  def self.available_roles_for(user_type)
    case user_type
    when "Company"
      roles = find(:all, :conditions => {:name => 'company'}).map {|role| [role.title, role.id]}
      default_role = find(:first, :conditions => {:name => roles.first[0]} )
    when "Faculty"
      roles = find(:all, :conditions => {:name => 'faculty'}).map {|role| [role.title, role.id]}
      default_role = find(:first, :conditions => {:name => roles.first[0]} )
    when "Student"
      roles = find(:all, :conditions => ["name = ? or name = ? or name = ?", 'admin', 'jobadmin', 'student']).map {|role| [role.title, role.id]}
      default_role = find(:first, :conditions => {:name => "Student"})
    end
    return roles, default_role
  end
end
