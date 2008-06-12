class JobLink < ActiveRecord::Base
  include LoggerSystem
  acts_as_loggable
  belongs_to :author, :class_name => "User", :foreign_key=>"author_id"
  belongs_to :last_editor, :class_name => "User", :foreign_key=>"last_editor_id"
  acts_as_list
  validates_presence_of :title
  validates_format_of :target, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix, :message => "muss eine korrekte URL sein, mit \"http://\"."
  acts_as_textiled :description
  localized_names "Der Praktikums-Link", :title => "Der Titel", :target => "Das Ziel"
  
  def move_higher=(param)
    self.move_higher if param
  end

  def move_lower=(param)
    self.move_lower if param
  end
end
