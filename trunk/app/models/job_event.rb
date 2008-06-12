class JobEvent < ActiveRecord::Base
  include LoggerSystem
  acts_as_loggable
  belongs_to :author, :class_name => "User", :foreign_key=>"author_id"
  belongs_to :last_editor, :class_name => "User", :foreign_key=>"last_editor_id"
  has_one :attachment, :as => :attachable, :dependent => :destroy
  validates_associated :attachment
  validates_presence_of :title, :description, :place
  acts_as_textiled :description
  localized_names "Der Veranstaltungshinweis", :title => "Der Titel", :description => "Die Beschreibung", :place => "Der Ort"
    
  def self.find_ordered(options = {})
    with_scope :find => options do
      order_option = options.include?(:order) ? options[:order] : 'time'
      find(:all, :order => order_option)
    end
  end

  def self.find_expired(options = {})
    with_scope :find => options do
      find_ordered(:conditions => "time < NOW()")
    end
  end
  
  def self.find_current(options = {})
    with_scope :find => options do
      find_ordered(:conditions => "time >= NOW()")
    end
  end
end
