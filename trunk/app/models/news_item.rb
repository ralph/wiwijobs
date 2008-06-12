class NewsItem < ActiveRecord::Base
  belongs_to :author, :class_name => "User", :foreign_key=> "author_id"
  belongs_to :last_editor, :class_name => "User", :foreign_key=> "last_editor_id"
  belongs_to :category, :class_name => "NewsCategory", :foreign_key=> "category_id"
  validates_presence_of :title, :text
  acts_as_textiled :text
  localized_names "Der News-Artikel", :title => "Der Titel", :text => "Der Text"
end
