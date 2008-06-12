class NewsCategory < Category
  has_many :news_items, :foreign_key=>"category_id"
  acts_as_list :scope => "parent_id"
  acts_as_tree :order => "title"
end
