class Job < ActiveRecord::Base
  include LoggerSystem
  acts_as_loggable
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :last_editor, :class_name => "User", :foreign_key => "last_editor_id"
  has_one :attachment, :as => :attachable, :dependent => :destroy
  has_and_belongs_to_many :categories, :class_name => "JobCategory"
  validates_associated :attachment
  validates_presence_of :title, :description, :company
  attr_protected :published_at
  acts_as_textiled :description, :contact_data
  localized_names "Das Job-Angebot",
    :title => "Der Titel",
    :description => "Die Beschreibung",
    :place => "Der Ort",
    :company => "Das Unternehmen"

  def teaser_text(length = 200, truncate_string = "...")
    if self.description_source.length >= length:
      shortened = self.description_source[0, length]
      splitted = shortened.split(/\s/)
      self.description = splitted.join(" ") + truncate_string
    end
    self.description
  end
  
  def salary_string
    if salary?:
      "Ja"
    else
      "Nein"
    end
  end
  
  def categories_string
    categories.collect{|category|category.title}.to_sentence
  end
  
  def published
    published_at
  end

  def published=(value)
    self.publish if (value == "1" and is_pending?)
    self.unpublish if (value == "0")
  end
  
  def publish
    self.published_at = Time.now if self.is_pending?
  end
  
  def unpublish
    self.published_at = nil
  end
  
  def is_published?
    published_at.to_i != 0
  end
  
  def is_pending?
    !is_published?
  end

  def is_expired?
    published_until < Time.now
  end

  def status
    return :expired if is_expired?
    is_published? ? :published : :pending
  end
  
  def set_default_values
    self.published_until = 2.months.from_now
    self.description = "Weiteres siehe Anhang."
    self.published_at = Time.now
    self.categories << JobCategory.find_by_title("sonstiges")
  end
    
  # Class methods:
  def self.find_ordered(options = {})
    with_scope :find => options do
      order_option = options.include?(:order) ? options[:order] : 'published_at DESC'
      find(:all, :order => order_option)
    end
  end
  
  def self.find_expired(options = {})
    with_scope :find => options do
      find_ordered(:conditions => "published_until < NOW()")
    end
  end
  
  def self.find_current(options = {})
    with_scope :find => options do
      find_ordered(:conditions => "published_until >= NOW()")
    end
  end

  def self.find_unpublished(options = {})
    with_scope :find => options do
      find_ordered(:conditions => { :published_at => nil })
    end
  end

  def self.find_current_and_published(options = {})
    with_scope :find => options do
      find_ordered(:conditions => "published_until >= NOW() AND published_at <= NOW()")
    end
  end
end
